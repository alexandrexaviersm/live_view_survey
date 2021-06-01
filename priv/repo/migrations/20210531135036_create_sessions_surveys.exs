defmodule LiveViewSurvey.Repo.Migrations.CreateSessionsSurveys do
  use Ecto.Migration

  def change do
    create table(:sessions_surveys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :session_id, :binary_id, null: false

      add :survey_id, references(:surveys, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:sessions_surveys, [:survey_id])
    create unique_index(:sessions_surveys, [:session_id, :survey_id])
  end
end
