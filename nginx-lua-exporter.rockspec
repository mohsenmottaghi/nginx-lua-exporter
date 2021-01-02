package = "nginx-lua-exporter"
version = "0.2-0"

source = {
  url = "git://github.com/mohsenmottaghi/nginx-lua-exporter.git",
  tag = "0.2-0",
}

description = {
  summary = "NGINX lua exporter for Prometheus",
  homepage = "https://github.com/mohsenmottaghi/nginx-lua-exporter",
  license = "MIT"
}

dependencies = {
  "lua >= 5.1",
}

build = {
	type = "builtin",
	modules = {
		enet = {
			sources = {"enet.c"},
			libraries = {"enet"},
			incdirs = {"$(ENET_INCDIR)"},
			libdirs = {"$(ENET_LIBDIR)"}
		}
	}
}