require 'rails_helper'

RSpec.describe "Unsakini::Boards", type: :request do

  let(:valid_board_params) {
    {
      :board => {:name => "board name"},
      :encrypted_password => Faker::Crypto.md5
    }
  }
  let(:invalid_board_name_param) {
    {
      :board => {:name => nil},
      :encrypted_password => Faker::Crypto.md5
    }
  }
  let(:invalid_encrypted_password_param) {
    {
      :board => {:name => "board name"},
      :encrypted_password => nil
    }
  }

  context "Private Boards" do

    before(:each) do
      user_has_shared_board_scenario
    end

    describe "GET /unsakini/boards/:id" do

      it "returns http unauthorized" do
        get unsakini_board_path(@board)
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns http not_found" do
        get unsakini_board_path({id: 1000000}), headers: auth_headers(@user)
        expect(response).to have_http_status(:not_found)
      end

      it "returns http forbidden" do
        get unsakini_board_path(@board), headers: auth_headers(@user_2)
        expect(response).to have_http_status(:forbidden)
      end

      it "returns board resource" do
        # debugger
        get unsakini_board_path(@board), headers: auth_headers(@user)
        # debugger
        expect(response).to have_http_status(:ok)
        expect(response.body).to match_json_schema(:board)
        expect(response.body).to be_json_eql(serialize(@user_board))
      end
    end

    describe "PUT /unsakini/boards/:id" do

      it "returns http unauthorized" do
        put unsakini_board_path(@board)
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns http forbidden" do
        put unsakini_board_path(@board), params: valid_board_params, headers: auth_headers(@user_2), as: :json
        expect(response).to have_http_status(:forbidden)
      end

      it "returns http not_found" do
        put unsakini_board_path({id: 1000000}), params: valid_board_params, headers: auth_headers(@user), as: :json
        expect(response).to have_http_status(:not_found)
      end

      it "rejects invalide encrypted_password" do
        put unsakini_board_path(@board), params: invalid_encrypted_password_param, headers: auth_headers(@user), as: :json
        expect(response).to have_http_status(:unprocessable_entity)
        @board.reload
        @user_board.reload
        expect(@board.name).not_to eq(invalid_encrypted_password_param[:board][:name])
        expect(@user_board.encrypted_password).not_to eq(invalid_encrypted_password_param[:encrypted_password])
      end

      it "accepts invalid board name" do
        put unsakini_board_path(@board), params: invalid_board_name_param, headers: auth_headers(@user), as: :json
        expect(response).to have_http_status(:ok)
        @board.reload
        @user_board.reload
        expect(@board.name).not_to be_falsy
        expect(@user_board.encrypted_password).to eq(invalid_board_name_param[:encrypted_password])
      end

      it "updates the board resource" do
        put unsakini_board_path(@board), params: valid_board_params, headers: auth_headers(@user), as: :json
        expect(response).to have_http_status(:ok)
        expect(response.body).to match_json_schema(:board)
        expect(body_to_json['board']['name']).to eq(valid_board_params[:board][:name])
        expect(body_to_json['encrypted_password']).to eq(valid_board_params[:encrypted_password])
        @user_board.reload
        expect(response.body).to be_json_eql(serialize(@user_board))
        expect(@board.user_boards.where.not(encrypted_password: '').first).to eq @user_board
        expect(@board.user_boards.where.not(encrypted_password: '').count).to eq 1
        expect(@shared_board.user_boards.where.not(encrypted_password: '').all).not_to be_nil
      end
    end

    describe "DELETE /unsakini/boards/:id" do

      it "returns http unauthorized" do
        delete unsakini_board_path(@board)
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns http forbidden if not board owner" do
        delete unsakini_board_path(@board), headers: auth_headers(@user_2), as: :json
        expect(response).to have_http_status(:forbidden)
      end

      it "returns http not_found" do
        delete unsakini_board_path({id: 1000000}), headers: auth_headers(@user), as: :json
        expect(response).to have_http_status(:not_found)
      end

      it "deletes the board resource and its post and comments" do
        expect(Unsakini::Board.find_by_id(@board.id)).not_to be_nil
        expect(Unsakini::UserBoard.where(board_id: @board.id).all).not_to be_empty
        expect(Unsakini::Post.where(board_id: @board.id).all).not_to be_empty
        expect(Unsakini::Comment.where(post_id: @post.id).all).not_to be_empty
        expect{delete unsakini_board_path(@board), headers: auth_headers(@user), as: :json}
        .to change{@user.boards.count}.by(-1)
        expect(response).to have_http_status(:ok)
        expect(Unsakini::Board.find_by_id(@board.id)).to be_nil
        expect(Unsakini::UserBoard.where(board_id: @board.id).all).to be_empty
        expect(Unsakini::Post.where(board_id: @board.id).all).to be_empty
        expect(Unsakini::Comment.where(post_id: @post.id).all).to be_empty
      end

    end

  end

end
