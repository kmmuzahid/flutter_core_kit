## 1.0.2

* **Web & Multi-Platform Support**: Replaced native `dart:io` imports with `universal_io` to ensure seamless compatibility across all platforms, including Flutter Web.
* **Resolved Dependency Conflicts**: Downgraded to stable releases of `file_picker` (`^11.0.2`) and `share_plus` (`^12.0.2`) to resolve win32 compatibility issues for web and desktop platforms.
* **Example App**: Added a full Flutter example application demonstrating core layout helpers, `CkTransport`, `CkStorage`, `CkListView` pagination, `CkAppBar`, and form validations.
* **Dartdoc Documentation**: Added comprehensive documentation comments to public APIs including `CoreKit`, `CoreKitConfig`, `CkResponse`, `CkTransportConfig`, and others.
* **Design Guidelines**: Documented best practices in `README.md` for using native-like `Ck` widgets and correctly applying responsive extensions (`.w`, `.h`, `.sp`, `.r`).
