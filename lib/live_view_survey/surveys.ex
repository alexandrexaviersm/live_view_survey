defmodule LiveViewSurvey.Surveys do
  @moduledoc """
  The Surveys context.
  """

  import Ecto.Query, warn: false
  alias LiveViewSurvey.Repo

  alias LiveViewSurvey.Surveys.Survey

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
  def get_survey!(id), do: Repo.get!(Survey, id)

  @doc """
  Creates a survey.

  ## Examples

      iex> create_survey(%{field: value})
      {:ok, %Survey{}}

      iex> create_survey(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_survey(attrs \\ %{}) do
    %Survey{}
    |> Survey.create_changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a survey.

  ## Examples

      iex> update_survey(survey, %{field: new_value})
      {:ok, %Survey{}}

      iex> update_survey(survey, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_survey(%Survey{} = survey, attrs) do
    survey
    |> Survey.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a survey.

  ## Examples

      iex> delete_survey(survey)
      {:ok, %Survey{}}

      iex> delete_survey(survey)
      {:error, %Ecto.Changeset{}}

  """
  def delete_survey(%Survey{} = survey) do
    Repo.delete(survey)
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

  def new_survey do
    Survey.changeset(%Survey{}, %{options: [%{id: Ecto.UUID.generate(), option: "Option 01"}]})
  end
end
