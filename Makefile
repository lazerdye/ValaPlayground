
streamcap: streamcap.vala
	valac --save-temps --pkg=gstreamer-0.10 --pkg=gstreamer-interfaces-0.10  --pkg=gstreamer-app-0.10 \
		--pkg=gdk-pixbuf-2.0 \
		streamcap.vala

clean:
	rm -f streamcap


