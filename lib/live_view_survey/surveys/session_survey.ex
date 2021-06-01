defmodule LiveViewSurvey.Surveys.SessionSurvey do
  use Ecto.Schema
  import Ecto.Changeset

  alias LiveViewSurvey.Surveys.Survey

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "sessions_surveys" do
    field :session_id, :binary_id

    belongs_to :survey, Survey

    timestamps()
  end

  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:session_id, :survey_id])
    |> validate_required([:session_id, :survey_id])
    |> unique_constraint([:session_id, :survey_id])
  end
end
