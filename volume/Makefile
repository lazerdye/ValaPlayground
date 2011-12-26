
volume: volume.vala
	valac --save-temps --pkg=gstreamer-0.10 --pkg=gstreamer-interfaces-0.10  --pkg=gstreamer-app-0.10 \
		--pkg=gdk-pixbuf-2.0 --pkg=liblircclient0 \
		--vapidir=../lirc \
		volume.vala

clean:
	rm -f volume volume.c


