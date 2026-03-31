// /// **🔒 Protected Access**
// ///
// /// This annotation restricts the visibility of a class to a specific folder depth.
// /// It is enforced by the `custom_lint` plugin.
// ///
// /// ### Access Rules:
// /// - **`depth = 1`** (Default): Accessible only from within the **same folder**.
// /// - **`depth = 2`**: Accessible from the same folder and its **immediate parent**.
// /// - **`depth = 3`**: Accessible up to the **grandparent** folder.
// ///
// /// ### Example Usage:
// /// ```dart
// /// @Protected(depth: 2)
// /// class MyInternalService {}
// /// ```
// class Protected {
//   /// The allowed folder distance for accessing this class.
//   final int depth;

//   /// **🔒 Protected Access**
//   ///
//   /// Restricts visibility to a folder depth.
//   /// - `depth = 1`: Same folder.
//   /// - `depth = 2`: Parent folder.
//   /// - `depth = 3`: Grandparent folder.
//   /// - `depth = ..`: so on.
//   const Protected([this.depth = 1]);
// }
