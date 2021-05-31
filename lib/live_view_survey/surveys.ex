defmodule LiveViewSurvey.Surveys do
  @moduledoc """
  The Surveys context.
  """

  import Ecto.Query, warn: false

  alias LiveViewSurvey.Repo
  alias LiveViewSurvey.Surveys.Survey

  @type option_id :: String.t()
  @type survey_id :: String.t()
  @type survey :: Survey.t()
  @type changeset :: Ecto.Changeset.t()

  @doc """
  Returns the list of surveys of the user.

  ## Examples

      iex> list_surveys(user_id)
      [%Survey{}, ...]

  """
  def list_surveys(user_id) do
    query = from s in Survey, where: s.created_by == ^user_id

    Repo.all(query)
  end

  @doc """
  Gets a single survey.

  Raises `Ecto.NoResultsError` if the Survey does not exist.

  ## Examples

      iex> get_survey!(123)
      %Survey{}

      iex> get_survey!(456)
      ** (Ecto.NoResultsError)

  """
  @spec get_survey!(survey_id) :: survey
  def get_survey!(id), do: Repo.get!(Survey, id)

  @doc """
  Creates a survey.

  ## Examples

      iex> create_survey(%{field: value})
      {:ok, %Survey{}}

      iex> create_survey(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  @spec create_survey(map) :: {:ok, survey} | {:error, changeset}
  def create_survey(attrs \\ %{}) do
    %Survey{}
    |> Survey.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Adds a vote to the survey option.
  """
  @spec updates_survey_option_vote(survey_id, option_id) :: {:ok, survey} | {:error, changeset}
  def updates_survey_option_vote(survey_id, option_id) do
    survey = get_survey!(survey_id)

    selected_option = Enum.find(survey.options, fn option -> option.id == option_id end)

    option_changeset = Ecto.Changeset.change(selected_option, votes: selected_option.votes + 1)

    options = Enum.reject(survey.options, fn option -> option.id == option_id end)

    survey
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:options, [option_changeset | options])
    |> Repo.update()
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking survey changes.

  ## Examples

      iex> change_survey(survey)
      %Ecto.Changeset{data: %Survey{}}

  """
  def change_survey(%Survey{} = survey, attrs \\ %{}) do
    Survey.changeset(survey, attrs)
  end

  @spec new_survey :: changeset
  def new_survey do
    Survey.changeset(%Survey{}, %{options: [%{id: Ecto.UUID.generate(), option: "Option 01"}]})
  end
end
