defmodule LiveViewSurvey.Factories do
  @moduledoc """
  Test Factories
  """

  alias Ecto.UUID
  alias LiveViewSurvey.Accounts.{User, UserToken}
  alias LiveViewSurvey.Surveys.Survey
  alias LiveViewSurvey.Surveys.SessionSurvey

  def survey(attrs \\ []) do
    attrs =
      [title: "Survey Test 01", created_by: UUID.generate()]
      |> Keyword.merge(attrs)

    struct(Survey, attrs)
  end

  def option(attrs \\ %{}) do
    %{id: UUID.generate(), option: "Survey Test 01", votes: 2}
    |> Map.merge(attrs)
  end

  def session_survey(attrs \\ []) do
    attrs =
      [session_id: UUID.generate(), survey_id: UUID.generate()]
      |> Keyword.merge(attrs)

    struct(SessionSurvey, attrs)
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
