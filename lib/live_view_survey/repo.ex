defmodule LiveViewSurvey.Repo do
  use Ecto.Repo,
    otp_app: :live_view_survey,
    adapter: Ecto.Adapters.Postgres
end
