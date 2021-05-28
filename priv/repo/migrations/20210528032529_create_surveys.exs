defmodule LiveViewSurvey.Repo.Migrations.CreateSurveys do
  use Ecto.Migration

  def change do
    create table(:surveys, primary_key: false) do
      add :id, :binary_id, primary_key: true
      add :title, :string, null: false
      add :created_by, references(:users, on_delete: :delete_all, type: :binary_id), null: false

      timestamps()
    end

    create index(:surveys, [:created_by])
  end
end
