defmodule LiveViewSurveyWeb.SurveyLive.ShowComponent do
  use LiveViewSurveyWeb, :live_component

  alias Ecto.Changeset
  alias LiveViewSurvey.Surveys

  def update(%{survey: survey} = assigns, socket) do
    changeset = survey_options_ordered_changeset(survey)

    {:ok,
     socket
     |> assign(assigns)
     |> assign(:changeset, changeset)
     |> assign(:chart_data, chart_data(survey))}
  end

  defp survey_options_ordered_changeset(survey) do
    Changeset.change(survey, options: Enum.sort_by(survey.options, & &1.option))
    |> Changeset.apply_changes()
    |> Surveys.change_survey()
  end

  defp chart_data(survey) do
    %{
      labels: Enum.map(survey.options, & &1.option),
      values: Enum.map(survey.options, & &1.votes)
    }
  end

  def render(assigns) do
    ~L"""
    <h1>Survey results</h1>
    <h2><%= @survey.title %></h2>
      <div id="charting">
        <canvas id="chart-canvas"
                phx-hook="BarChart"
                data-chart-data="<%= Jason.encode!(@chart_data) %>">
        </canvas>
      </div>
    """
  end
end
