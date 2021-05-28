defmodule LiveViewSurvey.Factories do
  @moduledoc """
  Test Factories
  """

  alias Ecto.UUID
  alias LiveViewSurvey.Accounts.{User, UserToken}
  alias LiveViewSurvey.Surveys.Survey

  def survey(attrs \\ []) do
    attrs =
      [title: "Survey Test 01", created_by: UUID.generate()]
      |> Keyword.merge(attrs)

    struct(Survey, attrs)
  end

  def user(attrs \\ []) do
    attrs =
      [email: "test@gmail.com", hashed_password: "0123456789"]
      |> Keyword.merge(attrs)

    struct(User, attrs)
  end

  def user_token(attrs \\ []) do
    attrs =
      [token: "", context: "session"]
      |> Keyword.merge(attrs)

    struct(UserToken, attrs)
  end
end
