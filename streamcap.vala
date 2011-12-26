using GLib;
using Gst;
using Gdk;

public errordomain CaptureError {
  LIVE_NOT_SUPPORTED,
  PLAYBACK_FAILURE,
  SNAPSHOT_FAILURE
}

public class StreamCap : GLib.Object {

  const OptionEntry[] option_entries = {
    { "delay", 'd', 0, OptionArg.INT, ref delay, "Delay in seconds", "DELAY" },
    { "", 0, 0, OptionArg.FILENAME_ARRAY, ref filenames, null, "FILE" },
    { null }
  };

  static int delay = 5;
  [CCode (array_length = false, array_null_terminated = true)]
  static string[] filenames;

  public static int main(string[] args) {
    Gst.init(ref args);

    try {
      var opt_context = new OptionContext("- Get snapshot of video");
      opt_context.set_help_enabled(true);
      opt_context.add_main_entries(option_entries, "pags");
      opt_context.parse(ref args);
    } catch (OptionError e) {
      stderr.printf("Option parsing failed: %s\n", e.message);
      return -1;
    }

    stdout.printf("Delay: %d\n", delay);
    stdout.printf("%d files\n", filenames.length);

    if (filenames.length == 0) {
      stderr.printf("No filenames specified\n");
      return -1;
    }

    bool any_failures = false;
    foreach (string url in filenames) {
      try {
        GetSnapshot(url, delay);
      } catch (Error e) {
        stderr.printf("Error getting snapshot for %s: %s\n", url, e.message);
        any_failures = true;
      }
    }

    return any_failures ? 1 : 0;
  }

  public static void GetSnapshot(string url, int delay) throws GLib.Error, CaptureError {
    var cap_string = "video/x-raw-rgb,width=160,pixel-aspect-ratio=1/1,bpp=(int)24,depth=(int)24,endianness=(int)4321,red_mask=(int)0xff0000, green_mask=(int)0x00ff00, blue_mask=(int)0x0000ff";
    var pipeline_spec = @"uridecodebin uri=$url ! ffmpegcolorspace ! videoscale ! appsink name=sink caps=\"$cap_string\"";
    stdout.printf(@"Creating pipeline: $pipeline_spec\n");
    var pipeline = Gst.parse_launch(pipeline_spec);
    Gst.AppSink sink = (Gst.AppSink)((Gst.Bin)pipeline).get_by_name("sink");

    var ret = pipeline.set_state(State.PAUSED);
    if (ret == StateChangeReturn.FAILURE) {
      throw new CaptureError.PLAYBACK_FAILURE("Failed to play (1)");
    }
    if (ret == StateChangeReturn.NO_PREROLL) {
      throw new CaptureError.LIVE_NOT_SUPPORTED("Live sources not supported");
    }
    ret = pipeline.get_state(null, null, 5 * Gst.SECOND);
    if (ret == StateChangeReturn.FAILURE) {
      throw new CaptureError.PLAYBACK_FAILURE("Failed to play (2)");
    }

    int64 duration = 1;
    Gst.Format format = Gst.Format.TIME;
    pipeline.query_duration(ref format, out duration);
    duration = duration / Gst.SECOND;

    stdout.printf("Duration: %ld\n", (long)duration);

    var position = (long)delay * Gst.SECOND;
    pipeline.seek_simple(Gst.Format.TIME, Gst.SeekFlags.FLUSH, position);

    var buffer = sink.pull_preroll();

    if (buffer == null) {
      throw new CaptureError.SNAPSHOT_FAILURE("Could not get preroll buffer");
    }
    Gst.Caps caps = buffer.caps;
    if (caps == null) {
      throw new CaptureError.SNAPSHOT_FAILURE("Could not get buffer caps");
    }
    Gst.Structure structure = caps.get_structure(0);
    var width = 0, height = 0;
    structure.get_int("width", out width);
    structure.get_int("height", out height);
    stdout.printf("%d x %d\n", width, height);
  
    var width_rowstride = ((width * 3) + 3) & ~3;
    var pixbuf = new Pixbuf.from_data(buffer.data, Gdk.Colorspace.RGB, false, 8, width, height,
            width_rowstride, null);

    pixbuf.save("snapshot.png", "png", null, null);
    
    pipeline.set_state(Gst.State.NULL);
  }
}
