defmodule GraphicManipulations do
  import Mogrify

  @moduledoc """
  Documentation for GraphicManipulations.
  """

  @doc """
  Resize an image

  Returns %Mogrify.Image{}.

  Options: [path: "path_to_img", in_place: boolean]
  # 1. Will save to a temp file
  # 2. Will replace the image
  # 3. Will save to root

  ## Examples
      iex> GraphicManipulations.resize("bitstrings.png", "gif", 200, 113)
      iex> GraphicManipulations.resize("bitstrings_1.png", "gif", 2000, 1000, [in_place: true])
      iex> GraphicManipulations.resize("bitstrings.png", "gif", 200, 113, [path: "bitstrings_resized.gif"])
      %Mogrify.Image{
        animated: false,
        dirty: %{},
        ext: ".gif",
        format: "gif",
        frame_count: 1,
        height: nil,
        operations: [],
        path: "bitstrings_resized.gif",
        width: nil
      }
      iex> GraphicManipulations.resize("bitstrings.png", "gifx", 200, 113, [path: "bitstrings_resized.gifx"])
      {:error, "Supplied format gifx not supported"}

  """
  def resize(path, format, width, height, opts \\ [])

  def resize(path, format, width, height, opts) when format == "png" do
    open(path)
    |> resize_to_limit(~s(#{width}x#{height}))
    |> save(opts)
  end

  def resize(path, format, width, height, opts) when format == "gif" do
    open(path)
    |> resize_to_limit(~s(#{width}x#{height}))
    |> format("gif")
    |> save(opts)
  end

  def resize(_path, format, _width, _height, _opts) do
    {:error, "Supplied format #{format} not supported"}
  end
end
