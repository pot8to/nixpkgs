{ stdenv, fetchurl, foomatic-filters, bc, unzip, ghostscript, systemd, vim }:

stdenv.mkDerivation rec {
  name = "foo2zjs-20160901";

  src = fetchurl {
    url = "http://www.loegria.net/mirrors/foo2zjs/${name}.tar.gz";
    sha256 = "0k2sva2xmqv4scl2q6v1rg76m52yigr6p2l5mljg982ygsi27fb2";
  };

  buildInputs = [ foomatic-filters bc unzip ghostscript systemd vim ];

  patches = [ ./no-hardcode-fw.diff ./hbpl1.patch ./foo2hbpl1.c.print-quality.patch ];

  makeFlags = [
    "PREFIX=$(out)"
    "APPL=$(out)/share/applications"
    "PIXMAPS=$(out)/share/pixmaps"
    "UDEVBIN=$(out)/bin"
    "UDEVDIR=$(out)/etc/udev/rules.d"
    "UDEVD=${systemd}/sbin/udevd"
    "LIBUDEVDIR=$(out)/lib/udev/rules.d"
    "USBDIR=$(out)/etc/hotplug/usb"
    "FOODB=$(out)/share/foomatic/db/source"
    "MODEL=$(out)/share/cups/model"
  ];

  installFlags = [ "install-hotplug" ];

  postPatch = ''
    touch all-test
    sed -e "/BASENAME=/iPATH=$out/bin:$PATH" -i *-wrapper *-wrapper.in
    sed -e "s@PREFIX=/usr@PREFIX=$out@" -i *-wrapper{,.in}
    sed -e "s@/usr/share@$out/share@" -i hplj10xx_gui.tcl
    sed -e "s@\[.*-x.*/usr/bin/logger.*\]@type logger >/dev/null 2>\&1@" -i *wrapper{,.in}
    sed -e '/install-usermap/d' -i Makefile
    sed -e "s@/etc/hotplug/usb@$out&@" -i *rules*
    sed -e "s@/usr@$out@g" -i hplj1020.desktop
    sed -e "/PRINTERID=/s@=.*@=$out/bin/usb_printerid@" -i hplj1000
  '';

  preInstall = ''
    mkdir -pv $out/{etc/udev/rules.d,lib/udev/rules.d,etc/hotplug/usb}
    mkdir -pv $out/share/foomatic/db/source/{opt,printer,driver}
    mkdir -pv $out/share/cups/model
    mkdir -pv $out/share/{applications,pixmaps}

    mkdir -pv "$out/bin"
    cp -v getweb arm2hpdl "$out/bin"
  '';

  meta = with stdenv.lib; {
    description = "ZjStream printer drivers";
    maintainers = with maintainers;
    [
      raskin
    ];
    platforms = platforms.linux;
    license = licenses.gpl2Plus;
  };
}
