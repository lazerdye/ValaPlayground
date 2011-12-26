/* Vala Playground Code
 * Copyright (C) <2011> Terence Haddock <lazerdye@tripi.com>
 *
 * This library is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Library General Public
 * License as published by the Free Software Foundation; either
 * version 2 of the License, or (at your option) any later version.
 *
 * This library is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Library General Public License for more details.
 *
 * You should have received a copy of the GNU Library General Public
 * License along with this library; if not, write to the
 * Free Software Foundation, Inc., 59 Temple Place - Suite 330,
 * Boston, MA 02111-1307, USA.
 */

using Lirc;

/**
 * Control the volume using a remote control.
 */
public class Volume : GLib.Object {
  public static int testFunc(char* s) {
    stdout.printf("testFunc: %s\n", (string)s);
    return 0;
  }

  public static int main(string[] args) {
    var res = Lirc.init("volume", 1);
    stdout.printf("Res 1: %d\n", res);
    if (res != 0 && res != 3) {
      stdout.printf("Error 1\n");
      return 1;
    }

    Lirc.Config *config = null;
    res = Lirc.readconfig("lircrc", ref config);
    if (res != 0) {
      stdout.printf("Error 2\n");
      return 1;
    }

    char *code = null;
    char *c = null;
    while (Lirc.nextcode(&code) == 0) {
      stdout.printf("Code: %s", (string)code);
      if (code == null) continue;
      int ret;
      while ((ret=Lirc.code2char(config, code, &c)) == 0 && c != null)
      { 
        stdout.printf("Command \"%s\"\n", (string)c);
      }
      free(code);
      if (ret == -1) break;
    }

    Lirc.freeconfig(config);
    Lirc.deinit();

    return 0;
  }
}
