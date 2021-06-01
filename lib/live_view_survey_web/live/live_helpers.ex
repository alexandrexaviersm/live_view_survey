defmodule LiveViewSurveyWeb.LiveHelpers do
  @moduledoc """
  Helpers for LiveViews modules
  """
  alias LiveViewSurvey.Accounts
  import Phoenix.LiveView
  import Phoenix.LiveView.Helpers

  @doc """
  Renders a component inside the `LiveViewSurveyWeb.ModalComponent` component.

  The rendered modal receives a `:return_to` option to properly update
  the URL when the modal is closed.

  ## Examples

      <%= live_modal @socket, LiveViewSurveyWeb.SurveyLive.FormComponent,
        id: @survey.id || :new,
        action: @live_action,
        survey: @survey,
        return_to: Routes.survey_index_path(@socket, :index) %>
  """
  def live_modal(_socket, component, opts) do
    path = Keyword.fetch!(opts, :return_to)
    modal_opts = [id: :modal, return_to: path, component: component, opts: opts]
    live_component(LiveViewSurveyWeb.ModalComponent, modal_opts)
  end

  def assign_current_user(socket, session) do
    assign_new(socket, :current_user, fn ->
      Accounts.get_user_by_session_token(session["user_token"])
    end)
  end
end
