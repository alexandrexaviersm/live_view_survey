defmodule LiveViewSurveyWeb.SurveyAnswerLive do
  @moduledoc false
  use LiveViewSurveyWeb, :live_view

  alias LiveViewSurvey.Surveys

  def mount(_params, session, socket) do
    {:ok, assign(socket, voting_session_id: session["voting_session_id"])}
  end

  def handle_params(%{"id" => id}, _, socket) do
    survey = Surveys.get_survey!(id)

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

  def render(assigns) do
    ~L"""
    <h1>Take the survey</h1>
    <h2><%= @survey.title %></h2>
      <%= if @session_already_voted? do %>
        <div id="charting">
          <div phx-update="ignore">
            <canvas id="chart-canvas"
                    phx-hook="BarChart"
                    data-chart-data="<%= Jason.encode!(@chart_data) %>">
            </canvas>
          <div>
        </div>
      <% else %>
        <div id="take-survey">
          <div id="options">
            <%= f = form_for @changeset, "#", phx_submit: "save" %>
              <%= inputs_for f, :options, fn fp -> %>
                <div class="option" id="<%= fp.data.id %>">
                  <div class="flex items-center mr-4 mb-4">
                    <input id="radio-<%= fp.data.id %>" type="radio" name="option" value="<%= fp.data.id %>" class="hidden" />
                    <label for="radio-<%= fp.data.id %>" class="flex items-center cursor-pointer text-xl">
                      <span class="w-8 h-8 inline-block mr-2 rounded-full border border-grey flex-no-shrink"></span>
                      <div class="font-bold">
                        <%= fp.data.option %>
                      </div>
                    </label>
                  </div>
                </div>
              <% end %>
              <div class="text-center">
                <%= submit "Save", phx_disable_with: "Saving...", class: "btn" %>
              </div>
            </form>
          </div>
        </div>
      <% end %>
    """
  end
end
