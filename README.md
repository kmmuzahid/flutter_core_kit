<!--
 * @Author: Km Muzahid
 * @Date: 2026-01-05 11:18:19
 * @Email: km.muzahid@gmail.com
-->
# CoreKit

[![Version](https://img.shields.io/github/v/tag/kmmuzahid/flutter_core_kit?label=version)](https://github.com/kmmuzahid/flutter_core_kit/releases)

**CoreKit** is a comprehensive Flutter UI kit and service layer designed for building professional, production-ready applications with minimal boilerplate. It provides a complete ecosystem of widgets, networking, responsive utilities, and architectural patterns out of the box.

---

## Table of Contents

1. [CoreKit Widget (Main Entry)](#corekit-widget-main-entry)
2. [Installation](#installation)
3. [Configuration](#configuration)
4. [Navigation](#navigation)
5. [Text Fields](#text-fields)
6. [Buttons](#buttons)
7. [Display Widgets](#display-widgets)
8. [Images & Media](#images--media)
9. [Layout & Spacing](#layout--spacing)
10. [Forms & Validation](#forms--validation)
11. [Networking](#networking)
12. [Pickers & Selectors](#pickers--selectors)
13. [Dialogs & Overlays](#dialogs--overlays)
14. [Location Pickers](#location-pickers)
15. [Advanced Features](#advanced-features)
16. [Custom Lints](#custom-lints)
17. [License](#license)

---

## CoreKit Widget (Main Entry)

The **CoreKit** widget is the heart of the library. It initializes all services, manages the navigator key, and wraps your application with the necessary configurations. You must use either `CoreKit()` for standard routing or `CoreKit.router()` for declarative routing (go_router).

### Standard Routing (Navigator 1.0)

Use this when you prefer imperative navigation with `Navigator.push()` and `Navigator.pop()`. Perfect for simpler apps or when migrating existing codebases.

```dart
void main() {
  runApp(
    CoreKit(
      config: MyAppConfig(),  // Your configuration implementation
      home: const HomeScreen(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      title: 'My App',
    ),
  );
}
```

### Declarative Routing (Go Router / Navigator 2.0)

Use this for URL-based routing, deep linking, and web support. Ideal for complex navigation flows and when you need route-based state management.

```dart
void main() {
  final appRouter = AppRouter();  // Your go_router configuration
  
  runApp(
    CoreKit.router(
      config: MyAppConfig(),
      routerConfig: appRouter.config(),
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      title: 'My App',
    ),
  );
}
```

---

## Installation

Add CoreKit to your `pubspec.yaml` dependencies:

**Stable Release (Recommended):**
```yaml
dependencies:
  core_kit:
    git:
      url: https://github.com/kmmuzahid/flutter_core_kit.git
      ref: 1.0.0  # Check releases for latest version
```

**Development Branch:**
```yaml
dependencies:
  core_kit:
    git:
      url: https://github.com/kmmuzahid/flutter_core_kit.git
      ref: main
```

Then install:
```bash
flutter pub get
```

---

## Configuration

Create a configuration class that implements `CoreKitConfig`. This centralized approach ensures all required dependencies are properly configured before the app starts. Use `CoreKitConfigDefaults` mixin to provide default values for optional properties.

```dart
import 'package:core_kit/core_kit.dart';

class MyAppConfig extends CoreKitConfig with CoreKitConfigDefaults {
  @override
  String get imageBaseUrl => 'https://api.example.com/images/';
  
  @override
  DioServiceConfig get dioConfig => DioServiceConfig(
    baseUrl: 'https://api.example.com',
    refreshTokenEndpoint: '/auth/refresh',
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
  );
  
  @override
  TokenProvider get tokenProvider => TokenProvider(
    accessToken: () async => await storage.read('token'),
    refreshToken: () async => await storage.read('refresh_token'),
    updateTokens: (data) async {
      await storage.write('token', data['accessToken']);
      await storage.write('refresh_token', data['refreshToken']);
    },
  );
  
  // Optional: Customize app bar behavior
  @override
  AppbarConfig? get appbarConfig => AppbarConfig(
    onBack: () => Get.back(),
  );
  
  // Optional: Customize permission dialogs
  @override
  PermissionHelperConfig? get permissionHelperConfig => PermissionHelperConfig(
    permissionDenied: 'Access Denied',
    openSettings: 'Open Settings',
  );
}
```

---

## Navigation

CoreKit creates and manages a `GlobalKey<NavigatorState>` internally, exposing it via a static getter. This allows navigation from anywhere in your app without passing context through the widget tree.

```dart
// Navigate to a new screen from anywhere (business logic, services, etc.)
CoreKit.navigatorKey.currentState?.push(
  MaterialPageRoute(builder: (_) => ProfileScreen()),
);

// Pop current screen
CoreKit.navigatorKey.currentState?.pop();

// Access context for theme, media query, etc.
final context = CoreKit.navigatorKey.currentContext;
final theme = Theme.of(context);
```

---

## Text Fields

CoreKit provides a comprehensive set of text input widgets with built-in validation, responsive sizing, and consistent theming.

### CommonTextField

The primary text input widget supporting validation, custom styling, and various input types. Includes built-in validators for common use cases like email, password, phone numbers, and names.

```dart
CommonTextField(
  validationType: ValidationType.validateEmail,
  hintText: 'Enter your email',
  labelText: 'Email',
  onSaved: (value, controller) => email = value,
)
```

**Available validation types:**
- `validateEmail` - Validates email format
- `validatePassword` - Minimum 6 characters
- `validatePhone` - Phone number format
- `validateName` - Name with no special characters
- `validateConfirmPassword` - Matches original password
- `validateNumber` - Numeric input only
- `validateOptional` - No validation, just formatting

### CommonMultilineTextField

Multi-line text input perfect for descriptions, comments, or any long-form text. Features character and word counting with visual feedback.

```dart
CommonMultilineTextField(
  hintText: 'Enter description',
  maxLines: 5,
  maxLength: 500,  // Shows character counter
  maxWords: 100,   // Shows word counter
  validationType: ValidationType.validateOptional,
  onSaved: (value, controller) => description = value,
)
```

### CommonPhoneNumberTextField

International phone number input with country code selection via a searchable dropdown. Automatically formats numbers according to country standards.

```dart
CommonPhoneNumberTextField(
  hintText: 'Phone Number',
  initalCountryCode: 'BD',
  onChanged: (phoneNumber) {
    print(phoneNumber.completeNumber);  // +8801xxxxxxxxx
  },
)
```

### CommonDateInputTextField

Date picker integrated into a text field. Opens a calendar dialog when tapped and displays the selected date in a formatted string.

```dart
CommonDateInputTextField(
  hintText: 'Select Date',
  firstDate: DateTime(2020),
  lastDate: DateTime(2030),
  onDateSelected: (date) => selectedDate = date,
)
```

---

## Buttons

Professional button widgets with loading states, responsive sizing, and customizable styling.

### CommonButton

The standard button widget featuring automatic width calculation, loading state support, and theme-aware styling. Perfect for form submissions and primary actions.

```dart
CommonButton(
  titleText: 'Submit',
  onTap: () => submitForm(),
  isLoading: isSubmitting,
  buttonWidth: 200,
  buttonHeight: 50,
)
```

### CommonSelectableButton

A toggle button that maintains selection state with visual feedback. Useful for toggles, filter selections, or plan/package selection interfaces.

```dart
CommonSelectableButton(
  title: 'Premium Plan',
  isSelected: isPremiumSelected,
  onTap: () => setState(() => isPremiumSelected = !isPremiumSelected),
  selectedColor: Colors.green,
  unselectedColor: Colors.grey,
)
```

---

## Display Widgets

Widgets for displaying text, ratings, and other visual content.

### CommonText

Enhanced text widget with responsive spacing (top, bottom, left, right) and built-in styling options. Eliminates the need to wrap Text widgets in Padding containers.

```dart
CommonText(
  text: 'Hello World',
  fontSize: 18,
  fontWeight: FontWeight.bold,
  textColor: Colors.blue,
  top: 10,    // 10.w responsive margin
  bottom: 10, // 10.h responsive margin
)
```

### CommonRichText

Compose rich text with multiple spans, different styles, and clickable regions. Perfect for legal text, formatted descriptions, or text with embedded links.

```dart
CommonRichText(
  richTextContent: [
    CommonSimpleRichTextContent(
      text: 'By signing up, you agree to our ',
      style: TextStyle(color: Colors.grey),
    ),
    CommonSimpleRichTextContent(
      text: 'Terms of Service',
      style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ontap: () => navigateToTerms(),
    ),
  ],
)
```

### CommonRatingBar

Interactive star rating widget supporting full, half, and custom rating increments. Includes tap and drag gestures for rating selection.

```dart
CommonRatingBar(
  initialRating: 3.5,
  onRatingUpdate: (rating) => setState(() => currentRating = rating),
  allowHalfRating: true,
  itemSize: 30,
)
```

### CommonTabBar

Simplified tab bar implementation with automatic view switching. Supports both text and icon tabs with customizable indicator styling.

```dart
CommonTabBar(
  tabs: ['Tab 1', 'Tab 2', 'Tab 3'],
  views: [
    Tab1Content(),
    Tab2Content(),
    Tab3Content(),
  ],
  initialIndex: 0,
)
```

---

## Images & Media

Widgets for handling images from network, assets, and user selection.

### CommonImage

Intelligent image widget that handles network images, asset images, and SVG files. Features automatic caching, placeholder support, and responsive sizing.

```dart
CommonImage(
  src: '/products/item123.jpg',  // Relative to imageBaseUrl
  size: 100,
  borderRadius: 12,
  fill: BoxFit.cover,
)
```

### CommonImagePicker

Single image picker presenting camera and gallery options in a bottom sheet. Returns a File object ready for upload or display.

```dart
CommonImagePicker(
  onImagePicked: (imageFile) {
    setState(() => selectedImage = imageFile);
  },
  placeholder: Icon(Icons.add_a_photo),
)
```

### CommonMultiImagePicker

Multi-image picker with drag-to-reorder functionality. Supports setting a maximum image count and displays thumbnails in a grid.

```dart
CommonMultiImagePicker(
  maxImages: 5,
  onImagesChanged: (imageFiles) {
    setState(() => selectedImages = imageFiles);
  },
)
```

---

## Layout & Spacing

CoreKit includes powerful responsive extensions that make building adaptive layouts effortless.

### Responsive Extensions

All extensions automatically scale based on screen dimensions relative to the design size (default: iPhone 14 Pro Max 428x926).

```dart
// Width scaling - scales proportionally to screen width
Container(width: 100.w)

// Height scaling - scales proportionally to screen height  
Container(height: 50.h)

// Font scaling - maintains readability across screen sizes
Text('Title', style: TextStyle(fontSize: 24.sp))

// Radius scaling - consistent corner roundness
Container(borderRadius: BorderRadius.circular(12.r))
```

### Gap Extensions

Quick vertical and horizontal spacing without creating SizedBox widgets manually.

```dart
Column(
  children: [
    Widget1(),
    20.height,  // SizedBox(height: 20.h)
    Widget2(),
    10.height,
    Widget3(),
  ],
)

Row(
  children: [
    Widget1(),
    16.width,   // SizedBox(width: 16.w)
    Widget2(),
  ],
)
```

---

## Forms & Validation

Complete form handling system with validation, submission, and state management.

### CustomForm

Wrapper widget that provides a FormKey for validation and saving. Handles form state and provides a builder pattern for clean code organization.

```dart
CustomForm(
  builder: (context, formKey) => Column(
    children: [
      CommonTextField(
        validationType: ValidationType.validateEmail,
        hintText: 'Email',
      ),
      CommonTextField(
        validationType: ValidationType.validatePassword,
        hintText: 'Password',
      ),
      CommonButton(
        titleText: 'Login',
        onTap: () {
          if (formKey.currentState?.validate() ?? false) {
            formKey.currentState?.save();
            // Proceed with login
          }
        },
      ),
    ],
  ),
)
```

---

## Networking

Integrated Dio service with automatic authentication handling, token refresh, and request queuing.

### Making API Requests

The DioService handles all network communication with automatic token injection, refresh on 401 errors, and response parsing.

```dart
final response = await DioService.instance.request<User>(
  input: RequestInput(
    endpoint: '/users',
    method: RequestMethod.get,
  ),
  responseBuilder: (data) => User.fromJson(data),
);

if (response.isSuccess) {
  final user = response.data;
} else {
  // Handle error - response.message contains error details
  print(response.message);
}
```

---

## Pickers & Selectors

Selection widgets for dropdowns, multiple selection, and radio groups.

### CommonDropDown

Generic dropdown supporting any data type with custom display builders. Features search functionality and responsive styling.

```dart
CommonDropDown<User>(
  items: users,
  hint: 'Select User',
  nameBuilder: (user) => user.name,
  onChanged: (user) => selectedUser = user,
)
```

### CommonMultipleSelector

Multi-selection widget with checkable items and customizable item rendering. Perfect for selecting categories, tags, or filters.

```dart
CommonMultipleSelector<String>(
  items: ['Option 1', 'Option 2', 'Option 3'],
  selectedItems: selectedOptions,
  onChanged: (items) => setState(() => selectedOptions = items),
  itemBuilder: (item, isSelected) => ListTile(
    title: Text(item),
    trailing: isSelected ? const Icon(Icons.check) : null,
  ),
)
```

### CommonRadioGroupFormField

Single-selection radio group integrated with Flutter's Form system. Supports validation and form state management.

```dart
CommonRadioGroupFormField<String>(
  options: [
    RadioOption('Option 1', 'opt1'),
    RadioOption('Option 2', 'opt2'),
  ],
  selectedValue: selectedValue,
  onChanged: (value) => setState(() => selectedValue = value),
)
```

---

## Dialogs & Overlays

Widgets for displaying dialogs, bottom sheets, and overlay notifications.

### CommonAppBar

Customizable app bar with automatic back button handling, configurable actions, and theme integration.

```dart
CommonAppBar(
  title: 'Home',
  onBackPress: () => Get.back(),
  appbarConfig: AppbarConfig(
    backIcon: const Icon(Icons.arrow_back),
    actions: [
      IconButton(
        icon: const Icon(Icons.settings),
        onPressed: () {},
      ),
    ],
  ),
)
```

### CommonAlert

Simple alert dialog for confirmations and actions. Provides consistent styling and easy dismissal handling.

```dart
CommonAlert(
  title: 'Confirm Delete',
  content: Text('Are you sure you want to delete?'),
  actionButtonTittle: 'Delete',
  cancelButtonTittle: 'Cancel',
  onTap: () => deleteItem(),
).show();
```

### CommonDraggableBottomSheet

Bottom sheet with drag-to-dismiss functionality and scrollable content. Supports min/max size constraints and smooth animations.

```dart
showModalBottomSheet(
  context: context,
  isScrollControlled: true,
  backgroundColor: Colors.transparent,
  builder: (context) => CommonDraggableBottomSheet(
    child: YourContent(),
    minChildSize: 0.3,
    maxChildSize: 0.9,
  ),
);
```

### Snackbar

Styled overlay notifications that appear above the current UI. Supports success, error, warning, and info types with appropriate colors.

```dart
showSnackBar(
  'Operation successful!',
  type: SnackBarType.success,
);
```

---

## Location Pickers

Widgets for location selection with country, state, and city hierarchy.

### Country, State, City Selection

Hierarchical location pickers that populate based on parent selections. Data is included in the package, no additional API calls required.

```dart
// Step 1: Select Country
CommonCountryPicker(
  onChanged: (country) => setState(() => selectedCountry = country),
)

// Step 2: Select State (requires country)
CommonStateDropdown(
  countryCode: selectedCountry.code,
  onChanged: (state) => setState(() => selectedState = state),
)

// Step 3: Select City (requires country and state)
CommonCityDropdown(
  countryCode: selectedCountry.code,
  stateCode: selectedState.code,
  onChanged: (city) => setState(() => selectedCity = city),
)
```

---

## Advanced Features

### Permissions

Request system permissions with styled dialogs explaining why the permission is needed. Handles both standard and permanently denied cases.

```dart
final granted = await PermissionHelper.request(Permission.camera);
if (granted) {
  // Proceed with camera operation
}
```

### Sharing

Share content with images and deep links to other apps. Automatically downloads and prepares images for sharing.

```dart
CommonShare(
  title: 'Check out this product!',
  deepLinkUrl: 'https://myapp.com/product/123',
  imageUrl: '/products/123.jpg',
).shareContent();
```

### Loading Indicator

Customizable loading spinner for async operations.

```dart
CommonLoader(
  size: 40,
  color: Colors.blue,
  strokeWidth: 3,
)
```

---

## Custom Lints

CoreKit provides a custom lint package for enhanced static analysis. The primary feature is the `@protected` annotation for visibility control.

### Installation

```yaml
dev_dependencies:
  core_kit_lints:
    git:
      url: https://github.com/kmmuzahid/flutter_core_kit.git
      ref: main
      path: tools/custom_lint
  flutter_lints: ^3.0.0

include: package:flutter_lints/flutter.yaml

analyzer:
  plugins:
    - custom_lint
```

### @protected Annotation

Restricts class visibility based on folder depth. Useful for creating internal APIs.

```dart
import 'package:core_kit/annotations/protected.dart';

// Only accessible from same folder
@Protected()
class InternalService {}

// Accessible from same folder and parent
@Protected(depth: 2)
class ModuleInternalService {}
```

| Depth | Access From |
|-------|-------------|
| `1` (default) | Same folder only |
| `2` | Same folder + immediate parent |
| `3` | Up to grandparent folder |

---

## License

MIT License - see [LICENSE](LICENSE) file for details.

## Author

**Km Muzahid** - km.muzahid@gmail.com

---

<p align="center">Built with for the Flutter community</p>


