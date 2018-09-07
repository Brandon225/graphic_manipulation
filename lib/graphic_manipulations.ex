defmodule GraphicManipulations do
  import Mogrify
  use Hound.Helpers
  import FFmpex
  use FFmpex.Options

  @fixture Path.join(__DIR__, "beach.MOV")
  @output_path Path.join(__DIR__, "beach.mp4")
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

  @doc """
    Resize video

    Returns {:ok, "path_to_video"}.

    ## Examples
        iex> GraphicManipulations.resize_video("beach.mp4", "beach_scaled.mp4", "0", "720")

  """
  def resize_video(input_path, _output_path, _width, _height) when is_nil(input_path) do
    {:error, "input_path is required!"}
  end

  def resize_video(input_path, output_path, width, height) when is_nil(output_path) do
    resize_video(input_path, "./", width, height)
  end

  def resize_video(input_path, output_path, width, height) when width === "" do
    resize_video(input_path, output_path, "0", height)
  end

  def resize_video(input_path, output_path, width, height) when height === "" do
    resize_video(input_path, output_path, width, "0")
  end

  def resize_video(input_path, output_path, width, height) when width === "0" do
    resize_video(input_path, output_path, "trunc(oh*a/2)*2:#{height}")
  end

  def resize_video(input_path, output_path, width, height) when height === "0" do
    resize_video(input_path, output_path, "#{width}:trunc(ow/a/2)*2")
  end

  def resize_video(input_path, output_path, width, height) do
    resize_video(input_path, output_path, "#{width}:#{height}")
  end

  def resize_video(input_path, output_path, scale) do
    command =
      FFmpex.new_command()
      |> add_global_option(option_y())
      |> add_input_file(input_path)
      |> add_output_file(output_path)
      |> add_stream_specifier(stream_type: :video)
      |> add_file_option(option_aspect(scale))

    IO.inspect(prepare(command), label: "command")

    :ok = execute(command)
  end

  def video() do
    video(@fixture, @output_path)
  end

  def video(input_path, output_path) do
    command =
      FFmpex.new_command()
      |> add_global_option(option_y())
      |> add_input_file(input_path)
      |> add_output_file(output_path)
      |> add_stream_specifier(stream_type: :video)
      |> add_stream_option(option_b("64k"))
      |> add_file_option(option_maxrate("128k"))
      |> add_file_option(option_bufsize("64k"))

    :ok = execute(command)
  end

  def start do
    IO.puts("starting")

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
        iex> GraphicManipulations.screenshot("screenshot.gif")
        "./screenshot.gif"
  """
  def screenshot(save_to_path) do
    Hound.start_session()
    # visit the website which shows the visitor's IP
    # navigate_to("http://icanhazip.com")

    # display its raw source
    # IO.inspect(page_source())
    navigate_to("http://snippets.reimagin8d.com/about/")
    take_screenshot(save_to_path)
    Hound.end_session()
  end
end
