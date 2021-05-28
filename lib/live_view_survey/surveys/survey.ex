defmodule LiveViewSurvey.Surveys.Survey do
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
  end

  @doc false
  def changeset(survey, %{} = attrs) do
    survey
    |> cast(attrs, [:title])
    |> validate_required([:title])
  end

  def changeset(survey, attrs) do
    survey
    |> cast(attrs, [:title])
    |> validate_required([:title])
    |> put_assoc(:user, attrs["current_user"])
  end
end
