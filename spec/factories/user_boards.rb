FactoryGirl.define do
  factory :user_board do
    user_id nil
    board_id nil
    is_admin true
    encrypted_password "some secret text"
  end
end
