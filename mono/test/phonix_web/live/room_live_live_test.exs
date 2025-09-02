defmodule PhonixWeb.RoomLiveTest do
  use PhonixWeb.ConnCase

  import Phoenix.LiveViewTest
  import Phonix.CallsFixtures

  @create_attrs %{name: "some name", password_hash: "some password_hash"}
  @update_attrs %{name: "some updated name", password_hash: "some updated password_hash"}
  @invalid_attrs %{name: nil, password_hash: nil}

  setup :register_and_log_in_user

  defp create_room_live(%{scope: scope}) do
    room_live = room_live_fixture(scope)

    %{room_live: room_live}
  end

  describe "Index" do
    setup [:create_room_live]

    test "lists all rooms", %{conn: conn, room_live: room_live} do
      {:ok, _index_live, html} = live(conn, ~p"/rooms")

      assert html =~ "Listing Rooms"
      assert html =~ room_live.name
    end

    test "saves new room_live", %{conn: conn} do
      {:ok, index_live, _html} = live(conn, ~p"/rooms")

      assert {:ok, form_live, _} =
               index_live
               |> element("a", "New Room live")
               |> render_click()
               |> follow_redirect(conn, ~p"/rooms/new")

      assert render(form_live) =~ "New Room live"

      assert form_live
             |> form("#room_live-form", room_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#room_live-form", room_live: @create_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/rooms")

      html = render(index_live)
      assert html =~ "Room live created successfully"
      assert html =~ "some name"
    end

    test "updates room_live in listing", %{conn: conn, room_live: room_live} do
      {:ok, index_live, _html} = live(conn, ~p"/rooms")

      assert {:ok, form_live, _html} =
               index_live
               |> element("#rooms-#{room_live.id} a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/rooms/#{room_live}/edit")

      assert render(form_live) =~ "Edit Room live"

      assert form_live
             |> form("#room_live-form", room_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, index_live, _html} =
               form_live
               |> form("#room_live-form", room_live: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/rooms")

      html = render(index_live)
      assert html =~ "Room live updated successfully"
      assert html =~ "some updated name"
    end

    test "deletes room_live in listing", %{conn: conn, room_live: room_live} do
      {:ok, index_live, _html} = live(conn, ~p"/rooms")

      assert index_live |> element("#rooms-#{room_live.id} a", "Delete") |> render_click()
      refute has_element?(index_live, "#rooms-#{room_live.id}")
    end
  end

  describe "Show" do
    setup [:create_room_live]

    test "displays room_live", %{conn: conn, room_live: room_live} do
      {:ok, _show_live, html} = live(conn, ~p"/rooms/#{room_live}")

      assert html =~ "Show Room live"
      assert html =~ room_live.name
    end

    test "updates room_live and returns to show", %{conn: conn, room_live: room_live} do
      {:ok, show_live, _html} = live(conn, ~p"/rooms/#{room_live}")

      assert {:ok, form_live, _} =
               show_live
               |> element("a", "Edit")
               |> render_click()
               |> follow_redirect(conn, ~p"/rooms/#{room_live}/edit?return_to=show")

      assert render(form_live) =~ "Edit Room live"

      assert form_live
             |> form("#room_live-form", room_live: @invalid_attrs)
             |> render_change() =~ "can&#39;t be blank"

      assert {:ok, show_live, _html} =
               form_live
               |> form("#room_live-form", room_live: @update_attrs)
               |> render_submit()
               |> follow_redirect(conn, ~p"/rooms/#{room_live}")

      html = render(show_live)
      assert html =~ "Room live updated successfully"
      assert html =~ "some updated name"
    end
  end
end
