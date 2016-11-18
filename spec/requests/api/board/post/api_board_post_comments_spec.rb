require 'rails_helper'

RSpec.describe "Api::Board::Post::Comments", type: :request do

  before(:each) do
    @user = create(:user)
    @user_2 = create(:user)

    @my_board = create(:board)
    @user_board = create(:user_board, {
                           is_admin: true,
                           user_id: @user.id,
                           board_id: @my_board.id
    })
    @my_post = create(:post, {
                        user_id: @user.id,
                        board_id: @my_board.id
    })
    @my_comment = create(:comment, {
                           user_id: @user.id,
                           post_id: @my_post.id
    })




    @shared_board = create(:board)
    @share_user_board_1 = create(:user_board, {
                                   is_admin: true,
                                   user_id: @user.id,
                                   board_id: @shared_board.id
    })
    @share_user_board_2 = create(:user_board, {
                                   is_admin: false,
                                   user_id: @user_2.id,
                                   board_id: @shared_board.id
    })
    @shared_post = create(:post, {
                            user_id: @user.id,
                            board_id: @shared_board.id
    })
    @shared_comment = create(:comment, {
                               user_id: @user.id,
                               post_id: @shared_post.id
    })
  end

  let(:valid_attributes) {
    {content: "my comment on this topic"}
  }

  let(:invalid_attributes) {
    {content: ""}
  }

  describe "Private board" do

    describe "Comments on my post" do

      it "returns http unauthorized" do
        get api_board_post_comments_path(@my_board, @my_post)
        expect(response).to have_http_status(:unauthorized)
      end

      it "returns http unauthorized" do
        put api_board_post_comment_path(@my_board, @my_post, @my_comment), params: valid_attributes, as: :json
        expect(response).to have_http_status(:unauthorized)
      end

      describe "As a post owner" do

        describe "Get comments" do
          it "returns http forbidden" do
            get api_board_post_comments_path(@my_board, @my_post), headers: auth_headers(@user_2)
            expect(response).to have_http_status(:forbidden)
          end

          it "returns http forbidden" do
            get api_board_post_comments_path(@shared_board, @my_post), headers: auth_headers(@user_2)
            expect(response).to have_http_status(:forbidden)
          end

          it "returns all comments" do
            get api_board_post_comments_path(@my_board, @my_post), headers: auth_headers(@user)
            expect(response).to have_http_status(:ok)
            expect(body_as_hash).to match(model_as_hash(@my_post.comments))
          end
        end

        describe "Creating comment to my post" do
          it "returns http unauthorized" do
            post api_board_post_comments_path(@my_board, @my_post), as: :json, params: valid_attributes
            expect(response).to have_http_status(:unauthorized)
          end
          it "returns http forbidden" do
            post(
              api_board_post_comments_path(@my_board, @my_post),
              headers:  auth_headers(@user_2),
              params:   valid_attributes,
              as:       :json
            )
            expect(response).to have_http_status(:forbidden)
          end
          it "returns http forbidden" do
            post(
              api_board_post_comments_path(@my_board, @my_post),
              headers:  auth_headers(@user_2),
              params:   valid_attributes,
              as:       :json
            )
            expect(response).to have_http_status(:forbidden)
          end
          it "returns http unprocessable_entity" do
            post(
              api_board_post_comments_path(@my_board, @my_post),
              headers:  auth_headers(@user),
              params:   invalid_attributes,
              as:       :json
            )
            expect(response).to have_http_status(:unprocessable_entity)
          end
          it "creates a new comment" do
            comment_count = @my_post.comments.count
            post(
              api_board_post_comments_path(@my_board, @my_post),
              headers:    auth_headers(@user),
              params:     valid_attributes,
              as:         :json
            )
            expect(response).to have_http_status(:ok)
            expect(body_as_hash).to match(model_as_hash(@my_post.comments.last))
            expect(@my_post.comments.count).to eq(comment_count+1)
          end
        end

        describe "Updating my comment on my post" do
          it "returns http forbidden if not comment owner" do
            put(
              api_board_post_comment_path(@my_board, @my_post, @my_comment),
              params:   valid_attributes,
              headers:  auth_headers(@user_2),
              as:       :json
            )
            expect(response).to have_http_status(:forbidden)
          end
          it "updates my comment if user is me" do
            put(
              api_board_post_comment_path(@my_board, @my_post, @my_comment),
              params:   valid_attributes,
              headers:  auth_headers(@user),
              as:       :json
            )
            expect(response).to have_http_status(:ok)
            expect(body_as_hash[:content]).to eq(valid_attributes[:content])
          end
        end

      end
    end
  end
end
