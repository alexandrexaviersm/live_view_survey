defmodule LiveViewSurveyWeb.HomeLiveTest do
  use LiveViewSurveyWeb.ConnCase, async: true

  import Phoenix.LiveViewTest

  test "redirects to login page if user is not logged in", %{conn: conn} do
    assert {:error, {:live_redirect, %{to: "/users/log_in"}}} = live(conn, "/")
  end

  test "redirects to survey page if user is logged in", %{conn: conn} do
    user = Repo.insert!(Factories.user())

    assert {:error, {:live_redirect, %{to: "/surveys"}}} =
             conn
             |> log_in_user(user)
             |> live("/")
  end
end
