defmodule TunezWeb.Artists.FormLive do
  use TunezWeb, :live_view

  def mount(_params, _session, socket) do
    form = Tunez.Music.form_to_create_artist()

    socket =
      socket
      |> assign(:form, to_form(form))
      |> assign(:page_title, "New Artist")

    {:ok, socket}
  end

  def render(assigns) do
    ~H"""
    <.header>
      <.h1>{@page_title}</.h1>
    </.header>

    <.simple_form
      :let={form}
      id="artist_form"
      as={:form}
      for={@form}
      phx-change="validate"
      phx-submit="save"
    >
      <.input field={form[:name]} label="Name" />
      <.input field={form[:biography]} type="textarea" label="Biography" />
      <:actions>
        <.button type="primary">Save</.button>
      </:actions>
    </.simple_form>
    """
  end

  def handle_event("validate", %{"form" => form_data}, socket) do
    socket =
      update(socket, :form, fn form ->
        AshPhoenix.Form.validate(form, form_data)
      end)

    {:noreply, socket}
  end

  def handle_event("save", %{"form" => form_data}, socket) do
    socket =
      case AshPhoenix.Form.submit(socket.assigns.form, params: form_data) do
        {:ok, _artist} ->
          socket
          |> put_flash(:info, "Artist saved successfully")
          |> push_navigate(to: ~p"/")

        {:error, form} ->
          socket
          |> put_flash(:error, "Could not save artist data")
          |> assign(:form, form)
      end

    {:noreply, socket}
  end
end
