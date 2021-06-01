defmodule LiveViewSurvey.Surveys do
  @moduledoc """
  The Surveys context.
  """

  import Ecto.Query, warn: false

  alias Ecto.Multi
  alias LiveViewSurvey.Repo
  alias LiveViewSurvey.Surveys.{Survey, SessionSurvey}

  @type option_id :: String.t()
  @type session_id :: String.t()
  @type survey_id :: String.t()
  @type survey :: Survey.t()
  @type changeset :: Ecto.Changeset.t()

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
  Returns the list of surveys of the user.

  ## Examples

      iex> list_surveys(user_id)
      [%Survey{}, ...]

  """
  def list_surveys(user_id) do
    query = from s in Survey, where: s.created_by == ^user_id, order_by: [{:desc, :inserted_at}]

    Repo.all(query)
  end

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
    |> broadcast(:survey_created)
  end

  @doc """
  Computes the vote to a Survey and record the running session that voted.
  """
  @spec vote(survey_id, option_id, session_id) :: {:ok, survey} | {:error, :transaction_failed}
  def vote(survey_id, option_id, session_id) do
    Multi.new()
    |> Multi.insert(:session_survey, create_session_survey(survey_id, session_id))
    |> Multi.update(:survey, updates_survey_option_vote_changes(survey_id, option_id))
    |> Repo.transaction()
    |> broadcast(:survey_updated)
  end

  def subscribe(topic) do
    Phoenix.PubSub.subscribe(LiveViewSurvey.PubSub, topic)
  end

  @doc """
  Checks if the running session already voted for this Survey.
  """
  @spec session_already_voted?(survey_id, session_id) :: boolean
  def session_already_voted?(survey_id, session_id) do
    Repo.get_by(SessionSurvey, session_id: session_id, survey_id: survey_id)
    |> case do
      nil -> false
      %SessionSurvey{} -> true
    end
  end

  @spec new_survey :: changeset
  def new_survey do
    Survey.changeset(%Survey{}, %{options: [%{id: Ecto.UUID.generate(), option: "Option 01"}]})
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking survey changes.

  ## Examples

      iex> change_survey(survey)
      %Ecto.Changeset{data: %Survey{}}

  """
  @spec change_survey(survey, map) :: changeset
  def change_survey(%Survey{} = survey, attrs \\ %{}) do
    Survey.changeset(survey, attrs)
  end

  defp create_session_survey(survey_id, session_id) do
    %SessionSurvey{}
    |> SessionSurvey.changeset(%{survey_id: survey_id, session_id: session_id})
  end

  defp updates_survey_option_vote_changes(survey_id, option_id) do
    survey = get_survey!(survey_id)

    selected_option = Enum.find(survey.options, fn option -> option.id == option_id end)

    option_changeset = Ecto.Changeset.change(selected_option, votes: selected_option.votes + 1)

    options = Enum.reject(survey.options, fn option -> option.id == option_id end)

    ordered_options =
      [option_changeset | options]
      |> Enum.sort_by(fn option ->
        case option do
          %Ecto.Changeset{data: data} -> data.option
          _ -> option.option
        end
      end)

    survey
    |> Ecto.Changeset.change()
    |> Ecto.Changeset.put_embed(:options, ordered_options)
  end

  defp broadcast({:ok, survey}, :survey_created) do
    Phoenix.PubSub.broadcast(
      LiveViewSurvey.PubSub,
      "user:#{survey.created_by}",
      :survey_created
    )

    {:ok, survey}
  end

  defp broadcast({:ok, %{survey: survey}}, :survey_updated) do
    Phoenix.PubSub.broadcast(
      LiveViewSurvey.PubSub,
      "survey:#{survey.id}",
      {:survey_updated, survey}
    )

    {:ok, survey}
  end

  defp broadcast({:error, _reason} = error, _event), do: error

  defp broadcast({:error, _failed_operation, _failed_value, _changes_so_far}, _event),
    do: {:error, :transaction_failed}
end
