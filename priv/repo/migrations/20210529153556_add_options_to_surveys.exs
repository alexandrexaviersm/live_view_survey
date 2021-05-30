defmodule LiveViewSurvey.Repo.Migrations.AddOptionsToSurveys do
  use Ecto.Migration

  def change do
    alter table(:surveys) do
      add :options, :jsonb, default: "[]"
    end
  end
end
