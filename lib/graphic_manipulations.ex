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
      iex> GraphicManipulations.resize("bitstrings.png", 200, 113)
      iex> GraphicManipulations.resize("bitstrings_1.png", 2000, 1000, [in_place: true])
      iex> GraphicManipulations.resize("bitstrings.png", 200, 113, [path: "bitstrings_resized.png"])
      %Mogrify.Image{
        animated: false,
        dirty: %{},
        ext: ".png",
        format: nil,
        frame_count: 1,
        height: nil,
        operations: [],
        path: "bitstrings_resized.png",
        width: nil
      }

  """
  def resize(path, width, height, opts \\ []) do
    open(path)
    |> resize_to_limit(~s(#{width}x#{height}))
    |> save(opts)
  end
end
