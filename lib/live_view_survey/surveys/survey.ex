defmodule LiveViewSurvey.Surveys.Survey do
  @moduledoc """
  Schema for the Surveys
  """
  use Ecto.Schema
  import Ecto.Changeset

  alias LiveViewSurvey.Accounts.User

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id
  schema "surveys" do
    field :title, :string
    field :created_by, :binary_id

    belongs_to :user, User, define_field: false, foreign_key: :created_by

    timestamps()

    embeds_many :options, Option do
      field :option, :string
      field :votes, :integer, default: 0
    end
  end

  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> cast_embed(:options, with: &options_changeset/2)
  end

  def create_changeset(survey, attrs) do
    survey
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> cast_embed(:options, with: &options_changeset/2, required: true)
    |> put_assoc(:user, attrs["current_user"])
  end

  def options_changeset(schema, attrs) do
    schema
    |> cast(attrs, [:id, :option])
    |> validate_required([:id, :option])
  end
end
