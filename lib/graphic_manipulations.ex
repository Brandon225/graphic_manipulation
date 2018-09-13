defmodule GraphicManipulations do
  import Mogrify
  use Hound.Helpers

  # @fixture Path.join(__DIR__, "beach.MOV")
  # @output_path Path.join(__DIR__, "beach.mp4")
  # @output_path Path.join(System.tmp_dir(), "ffmpex-test-fixture.avi")

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
      iex> GraphicManipulations.resize("media/bitstrings.png", "gif", 200, 113)
      iex> GraphicManipulations.resize("media/bitstrings_1.png", "gif", 2000, 1000, [in_place: true])
      iex> GraphicManipulations.resize("media/bitstrings.png", "gif", 200, 113, [path: "bitstrings_resized.gif"])
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
      iex> GraphicManipulations.resize("media/bitstrings.png", "gifx", 200, 113, [path: "bitstrings_resized.gifx"])
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

  # def animated_image(save_to_path) do
  #   # convert -loop 0 -delay 100 in1.png in2.png out.gif
  #   command = [
  #     path,
  #     "-loop",
  #     "0",
  #     "-delay",
  #     "100",
  #     "img.png",
  #     "img2.png",
  #     "img3.png",
  #     "img.gif",
  #     save_to_path
  #   ]

  #   IO.inspect(command, label: "command")
  #   System.cmd("convert", command)
  # end

  def animated_image(images, save_to_path) do
    # convert -loop 0 -delay 100 in1.png in2.png out.gif

    command =
      Enum.concat(images, [
        "-loop",
        "0",
        "-delay",
        "100",
        save_to_path
      ])

    IO.inspect(command, label: "command")
    System.cmd("convert", command)
  end

  def crop(path, %{top: top, left: left, width: width, height: height}) do
    # IO.inspect(width, label: "width")
    # IO.inspect(height, label: "height")
    # -crop 40x30+10+10  +repage  repage.gif
    # max_x = left + width
    # max_y = top + height
    command = [
      path,
      "-gravity",
      "NorthWest",
      "-crop",
      "#{width}x#{height}+#{left}+#{top}",
      "+repage",
      path
    ]

    IO.inspect(command, label: "command")
    System.cmd("magick", command)
  end

  @doc """
    Resize video

    Returns {:ok, "path_to_video"}.

    ## Examples

        iex> GraphicManipulations.resize_video("media/beach.MOV", "media/beach_0.mp4", "1280", "720")
        :ok
        iex> GraphicManipulations.resize_video("media/beach.mp4", "media/beach_1.mp4", "1280", "720")
        :ok
        iex> GraphicManipulations.resize_video("media/beach.mp4", "media/beach_2.mp4", "0", "720")
        :ok
        iex> GraphicManipulations.resize_video("media/beach.mp4", "media/beach_3.mp4", "1280", "0")
        :ok
        # iex> GraphicManipulations.resize_video("media/beach.mp4", "media/beach_4.mp4", "", 720)
        # :ok
        # iex> GraphicManipulations.resize_video("media/beach.mp4", "media/beach_5.mp4", "1280", "")
        # :ok
        # iex> GraphicManipulations.resize_video("", "media/beach_6.mp4", "1280", "0")
        # {:error, "input_path is required!"}
        # iex> GraphicManipulations.resize_v ideo("media/beach.mp4", "media/beach_7.mp4", "0", "0")
        # {:error, "Must supply either height or width"}

  """
  def resize_video(input_path, _output_path, _width, _height) when input_path === "" do
    {:error, "input_path is required!"}
  end

  def resize_video(input_path, output_path, width, height) when output_path === "" do
    resize_video(input_path, "./", width, height)
  end

  def resize_video(input_path, output_path, width, height) when width === "" do
    resize_video(input_path, output_path, "0", height)
  end

  def resize_video(input_path, output_path, width, height) when height === "" do
    resize_video(input_path, output_path, width, "0")
  end

  def resize_video(_input_path, _output_path, width, height)
      when width == "0" and height == "0" do
    {:error, "Must supply either height or width"}
  end

  def resize_video(input_path, output_path, width, height) when width === "0" do
    resize_video(input_path, output_path, "scale=-2:#{height}")
  end

  def resize_video(input_path, output_path, width, height) when height === "0" do
    resize_video(input_path, output_path, "scale=#{width}:-2")
  end

  def resize_video(input_path, output_path, width, height) do
    cmd = System.cmd("ffmpeg", ["-i", input_path, "-s", "#{width}x#{height}", output_path])

    case cmd do
      {"", 0} ->
        :ok

      {"", 1} ->
        {:error, "Conversion failed!"}

      _ ->
        {:error, "Unknown error!"}
    end
  end

  def resize_video(input_path, output_path, scale) do
    cmd = System.cmd("ffmpeg", ["-i", input_path, "-vf", scale, output_path])

    case cmd do
      {"", 0} ->
        :ok

      {"", 1} ->
        {:error, "Conversion failed!"}

      _ ->
        {:error, "Unknown error!"}
    end
  end

  def start do
    # IO.puts("starting")

    Hound.Session.make_capabilities(%{
      browserName: "chrome",
      chromeOptions: %{
        "args" => ["--headless", "--disable-gpu"],
        "binary" => "/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome"
      }
    })

    Hound.start_session()
    navigate_to("http://snippets.reimagin8d.com/about/")
  end

  @doc """
    Take a screenshot of a webpage

    ## Examples
        iex> GraphicManipulations.screenshot("http://snippets.reimagin8d.com/", nil, "media/screenshot", "gif")
        "./media/screenshot_html.gif"
        iex> GraphicManipulations.screenshot("http://snippets.reimagin8d.com/details/", %{id: "atom"}, "media/screenshot", "gif")
        "./media/screenshot_atom.gif"
  """
  def screenshot(url, elements, save_to_path, file_ext, opts \\ %{})

  def screenshot(url, elements, save_to_path, file_ext, opts) when is_nil(elements) do
    IO.inspect(elements, label: "elements should be nil")
    IO.inspect(url, label: "url")
    IO.inspect(save_to_path, label: "save_to_path")
    IO.inspect(file_ext, label: "file_ext")
    IO.inspect(opts, label: "opts")
    screenshot(url, %{tag: "html"}, save_to_path, file_ext, opts)
  end

  def screenshot(url, elements, save_to_path, file_ext, opts) do
    IO.inspect(elements, label: "elements")

    name = Map.get(:name, opts)

    Enum.each(elements, fn {type, element} ->
      IO.inspect(type, label: "type")
      IO.inspect(element, label: "element")
      IO.inspect(save_to_path <> "_" <> element <> "." <> file_ext, label: "path")
      element_to_image(url, type, element, save_to_path, element <> "." <> file_ext)
    end)
  end

  def element_to_image(url, type, element, save_to_path, name) do
    Hound.start_session()

    current_window_handle() |> maximize_window

    navigate_to(url)
    element = find_element(type, element)
    {width, height} = element_size(element)

    # IO.inspect(width, label: "width")
    # IO.inspect(height, label: "height")

    {left, top} = element_location(element)

    # IO.inspect(top, label: "top")
    # IO.inspect(left, label: "left")

    # set_window_size(current_window_handle(), width, height)
    move_to(element, top, left)

    IO.inspect(save_to_path <> name, label: "save image to path with name")
    take_screenshot(save_to_path <> name)

    crop(save_to_path, %{top: top, left: left, width: width, height: height})

    Hound.end_session()
  end

  @doc """
  Create gif images

  Returns {:ok, "save_to_path"}.

  ## Examples

      iex> GraphicManipulations.element_to_gif("https://portal.eltoro.com/", "tag", "body", "./media/", 4, 10, 0)
      {:ok, "./media/body.gif"}

  """
  def element_to_gif(url, type, element, save_to_path, frames, delay, index) do
    index = index + 1

    case index <= frames do
      true ->
        # name =
        element_to_image(url, type, element, save_to_path, "#{element}#{index}.png")
        start_gif_timer(url, type, element, save_to_path, frames, delay, index)

      false ->
        nil

        # TODO:  Call method to create gif
        # def animated_image(path, save_to_path, map) do
        images = Enum.into(1..frames, [], fn x -> "./#{save_to_path}#{element}#{x}.png" end)

        animated_image(images, "./" <> save_to_path <> element <> ".gif")
        # string = Enum.map_every(1..frames, fn x -> nil end)
        {:ok, "gif is ready " <> save_to_path}
    end
  end

  def start_gif_timer(url, type, element, save_to_path, frames, delay, index) do
    Process.send_after(
      element_to_gif(url, type, element, save_to_path, frames, delay, index),
      :work,
      delay
    )
  end
end
