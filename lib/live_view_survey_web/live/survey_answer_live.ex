defmodule LiveViewSurveyWeb.SurveyAnswerLive do
  @moduledoc false
  use LiveViewSurveyWeb, :live_view

  alias LiveViewSurvey.Surveys

  def mount(_params, session, socket) do
    {:ok, assign(socket, :voting_session_id, session["voting_session_id"])}
  end

  def handle_params(%{"id" => id}, _, socket) do
    survey = Surveys.get_survey!(id)

    {:noreply, assign(socket, survey: survey, changeset: Surveys.change_survey(survey, %{}))}
  end

  def handle_event("save", %{"option" => option_id}, socket) do
    Surveys.updates_survey_option_vote(socket.assigns.survey.id, option_id)
    |> case do
      {:ok, _survey} ->
        {:noreply, put_flash(socket, :info, "The vote was registered")}

      {:error, _} ->
        {:noreply, put_flash(socket, :error, "Error processing vote")}
    end
  end

  def handle_event("save", _, socket) do
    {:noreply, socket}
  end

  def render(assigns),
    do: ~L"""
    <h1>Take the survey</h1>
    <h2><%= @survey.title %></h2>
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
    """
end
