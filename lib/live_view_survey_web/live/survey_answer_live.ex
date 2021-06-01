defmodule LiveViewSurveyWeb.SurveyAnswerLive do
  @moduledoc false
  use LiveViewSurveyWeb, :live_view

  alias LiveViewSurvey.Surveys

  def mount(_params, session, socket) do
    {:ok, assign(socket, voting_session_id: session["voting_session_id"])}
  end

  def handle_params(%{"id" => id}, _, socket) do
    survey = Surveys.get_survey!(id)

    if connected?(socket), do: Surveys.subscribe("survey:#{id}")

    session_already_voted? =
      Surveys.session_already_voted?(survey.id, socket.assigns.voting_session_id)

    socket = maybe_put_flag(socket, session_already_voted?)

    {:noreply,
     assign(socket,
       survey: survey,
       session_already_voted?: session_already_voted?,
       changeset: Surveys.change_survey(survey, %{}),
       chart_data: %{
         labels: Enum.map(survey.options, & &1.option),
         values: Enum.map(survey.options, & &1.votes)
       }
     )}
  end

  defp maybe_put_flag(socket, true = _session_already_voted?) do
    put_flash(
      socket,
      :info,
      "You have already voted. Share this URL with others so they can vote too."
    )
  end

  defp maybe_put_flag(socket, false = _session_already_voted?), do: socket

  def handle_event("save", %{"option" => option_id}, socket) do
    Surveys.vote(socket.assigns.survey.id, option_id, socket.assigns.voting_session_id)
    |> case do
      {:ok, survey} ->
        socket =
          assign(socket,
            session_already_voted?: true,
            chart_data: %{
              labels: Enum.map(survey.options, & &1.option),
              values: Enum.map(survey.options, & &1.votes)
            }
          )

        {:noreply, put_flash(socket, :info, "The vote was registered")}

      {:error, :transaction_failed} ->
        {:noreply, put_flash(socket, :error, "Error processing vote")}
    end
  end

  def handle_event("save", _, socket) do
    {:noreply, socket}
  end

  def handle_info({:survey_updated, survey}, socket) do
    chart_data = %{
      labels: Enum.map(survey.options, & &1.option),
      values: Enum.map(survey.options, & &1.votes)
    }

    socket = push_event(socket, "update-votes", chart_data)

    {:noreply, socket}
  end
end
