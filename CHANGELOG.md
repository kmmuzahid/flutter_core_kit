## 1.0.5

* **State Abbreviation Support & Data Class**: Updated `CkStateDropDown` callbacks (`onChanged`, `selectedItemBuilder`, `nameBuilder`) to pass `CkStateDropDownItemProperty` containing both `stateName` and `abbreviation`.
* **Flexible Initial Selection**: Added `initialState` parameter to `CkStateDropDown` accepting either full state name (e.g. `'California'`) or state abbreviation (e.g. `'CA'`).
* **Smart City Dropdown**: Updated `CkCityDropDown`'s `selectedState` parameter to seamlessly handle state abbreviations as well as state names.
* **Built-in Abbreviation Dataset**: Added `StateAbbreviations` dataset supporting automatic abbreviation lookups for US States, Canadian Provinces, and Australian States.

## 1.0.4

* **Warning fixed**: Fixed linting warnings in `ck_auth_service.dart` and `request_builder.dart`.

## 1.0.3

* **License Update**: Changed package license to MIT.

## 1.0.2

* **Web & Multi-Platform Support**: Replaced native `dart:io` imports with `universal_io` to ensure seamless compatibility across all platforms, including Flutter Web.
* **Resolved Dependency Conflicts**: Downgraded to stable releases of `file_picker` (`^11.0.2`) and `share_plus` (`^12.0.2`) to resolve win32 compatibility issues for web and desktop platforms.
* **Example App**: Added a full Flutter example application demonstrating core layout helpers, `CkTransport`, `CkStorage`, `CkListView` pagination, `CkAppBar`, and form validations.
* **Dartdoc Documentation**: Added comprehensive documentation comments to public APIs including `CoreKit`, `CoreKitConfig`, `CkResponse`, `CkTransportConfig`, and others.
* **Design Guidelines**: Documented best practices in `README.md` for using native-like `Ck` widgets and correctly applying responsive extensions (`.w`, `.h`, `.sp`, `.r`).
