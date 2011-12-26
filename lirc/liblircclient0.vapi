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

[CCode (lower_case_cprefix="lirc_", cprefix="lirc_", cheader_filename="lirc/lirc_client.h")]
namespace Lirc
{
  [CCode (cname="struct lirc_config")]
  public struct Config {
    string current_mode;
    int sockfd;
  }

  static int init(string prog, int verbose);
  static int deinit();
  static int readconfig(char *file, ref Config* config, Lirc.CheckFn? check_fn = null);
  static int freeconfig(Config* config);
  static int code2char(Config* config, char* code, char **string);
  static int nextcode(char **code);

  [CCode (has_target = false)]
  public delegate int CheckFn(char* s);
}

