import sys
import time
import gi

gi.require_version('Gst', '1.0')
from gi.repository import Gst

# Initialize GStreamer
Gst.init(None)

def run_pipeline(loop_count, video_device, sink):
    for loop_index in range(loop_count):
        # Create a pipeline with the chosen sink and video device
        pipeline = Gst.parse_launch(
            f"v4l2src device={video_device} ! image/jpeg,width=1920,height=1080,framerate=30/1 ! vaapijpegdec ! videoconvert ! {sink}"
        )

        # Start playing the pipeline
        ret = pipeline.set_state(Gst.State.PLAYING)

        if ret == Gst.StateChangeReturn.FAILURE:
            print(f"Error: Pipeline failed to start in loop {loop_index + 1}. Exiting.")
            pipeline.set_state(Gst.State.NULL)
            break

        # Wait to confirm the pipeline transitions to PLAYING
        bus = pipeline.get_bus()
        msg = bus.timed_pop_filtered(5 * Gst.SECOND, Gst.MessageType.STATE_CHANGED)

        if not msg or msg.type != Gst.MessageType.STATE_CHANGED:
            print(f"Error: Pipeline did not transition to PLAYING state in loop {loop_index + 1}. Exiting.")
            pipeline.set_state(Gst.State.NULL)
            break

        print(f"Pipeline started successfully with video device '{video_device}' and sink '{sink}'. Loop {loop_index + 1} of {loop_count}.")
        time.sleep(10)

        # Stop the pipeline
        print(f"Stopping pipeline (loop {loop_index + 1}).")
        pipeline.set_state(Gst.State.NULL)
        time.sleep(5)

if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python gstreamer_video_loop.py <loop_count> <video_device> <sink>")
        print("Options for <sink>: autovideosink, fakesink")
        sys.exit(1)

    try:
        loop_count = int(sys.argv[1])
        if loop_count < 1:
            raise ValueError("Loop count must be at least 1.")
    except ValueError as e:
        print(f"Error: {e}")
        sys.exit(1)

    video_device = sys.argv[2]

    sink = sys.argv[3].lower()
    if sink not in ["autovideosink", "fakesink"]:
        print("Error: Invalid sink. Choose 'autovideosink' or 'fakesink'.")
        sys.exit(1)

    run_pipeline(loop_count, video_device, sink)
    print("Done.")

