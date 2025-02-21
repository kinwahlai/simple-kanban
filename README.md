# Simple Kanban

A simple, customizable Kanban board widget for Flutter applications.

> This widget was developed with the assistance of [Cursor](https://cursor.sh/), an AI-powered code editor.

## Features

- Modern, clean card design with subtle visual feedback
- Three columns with equal widths and height that expands to the container
- Headers and footers that stick to the top and bottom
- Headers with text labels and item count indicators
- Footers with plus icon and text field for adding new items
- Items displayed as cards with modern typography and layout
- Intuitive drag-and-drop reordering within columns
- Easy column-to-column movement with directional controls
- Flexible column limits (optional per column)
- Smart button states that reflect available actions
- Customizable themes and colors
- Responsive design that adapts to container size

### Card Features
- Clean, modern typography with optimized spacing
- Subtle gradient background for depth
- Grab cursor indicator for draggable items
- Elevation changes during drag operations
- Right-aligned movement controls
- Visual feedback for available actions
- Tooltips for better usability

### Column Features
- Item count with optional limit indicator
- Optional column limits (unlimited by default)
- Visual feedback when columns reach their limit
- Smooth drag-and-drop reordering
- Add new items through text input
- Customizable column titles and limits

## Examples

### Basic Usage

```dart
import 'package:simple_kanban/simple_kanban.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: KanbanBoard(),
      ),
    );
  }
}
```

### Mixed Limited and Unlimited Columns

```dart
KanbanBoard(
  columnTitles: ['Backlog', 'In Progress', 'Review', 'Done'],
  columnLimits: {
    'Backlog': null,        // Unlimited items
    'In Progress': 3,       // Limited to 3 items
    'Review': 2,           // Limited to 2 items
    'Done': null,          // Unlimited items
  },
  initialItems: {
    'Backlog': [
      KanbanItem(id: '1', title: 'Feature A', subtitle: 'Planning phase'),
      KanbanItem(id: '2', title: 'Feature B', subtitle: 'Research needed'),
      // Can add unlimited items
    ],
    'In Progress': [
      KanbanItem(id: '3', title: 'Feature C', subtitle: 'Coding in progress'),
      // Limited to 3 items
    ],
    'Review': [
      KanbanItem(id: '4', title: 'Feature D', subtitle: 'Ready for review'),
      // Limited to 2 items
    ],
    'Done': [
      KanbanItem(id: '5', title: 'Feature E', subtitle: 'Completed'),
      // Can add unlimited items
    ],
  },
)
```

### Custom Theme with Column Indicators

```dart
KanbanBoard(
  theme: KanbanBoardTheme(
    backgroundColor: Colors.grey.shade100,
    columnColor: Colors.white,
    cardColor: Colors.blue.shade50,
    cardBorderColor: Colors.blue.shade200,
    headerColor: Colors.blue.shade500,
    footerColor: Colors.white,
  ),
  columnTitles: ['To Do', 'Sprint', 'Done'],
  columnLimits: {
    'To Do': null,    // Backlog can have unlimited items
    'Sprint': 5,      // Sprint is limited to 5 active items
    'Done': null,     // Completed items are unlimited
  },
)
```

### Visual Indicators

The board provides clear visual feedback about column limits:

1. **Unlimited Columns**
   - Show only the current item count: "3"
   - Add button always enabled
   - Can always receive items from other columns

2. **Limited Columns**
   - Show count with limit: "3/5"
   - Add button disabled when full
   - Movement controls disabled when full
   - Visual feedback when attempting to exceed limit

## Common Use Cases

1. **Sprint Board**
   - Unlimited backlog column
   - Limited sprint column (team capacity)
   - Unlimited done column

2. **Workflow Board**
   - Unlimited intake column
   - Limited work-in-progress columns
   - Unlimited archive column

3. **Review System**
   - Unlimited submission column
   - Limited review column
   - Limited testing column
   - Unlimited approved column

## Getting Started

Add this to your package's `pubspec.yaml` file:

```yaml
dependencies:
  simple_kanban: ^0.1.0
```

## Usage

Basic usage:

```dart
import 'package:simple_kanban/simple_kanban.dart';

class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: KanbanBoard(),
      ),
    );
  }
}
```

### Customization

The KanbanBoard widget accepts several parameters for customization:

```dart
KanbanBoard(
  // Custom initial items for each column
  initialItems: {
    'To Do': [
      KanbanItem(
        id: '1',
        title: 'Task 1',
        subtitle: 'Description',
      ),
    ],
  },
  
  // Custom limits for each column (optional)
  // Columns without specified limits can hold unlimited items
  columnLimits: {
    'To Do': 6,        // Limited to 6 items
    'In Progress': 4,  // Limited to 4 items
    // 'Done' has no limit specified, so it can hold unlimited items
  },
  
  // Custom column titles
  columnTitles: ['Backlog', 'Doing', 'Completed'],
  
  // Custom theme
  theme: KanbanBoardTheme(
    backgroundColor: Colors.grey.shade100,
    columnColor: Colors.white,
    cardColor: Colors.blue.shade50,
    cardBorderColor: Colors.blue.shade200,
    headerColor: Colors.blue.shade500,
    footerColor: Colors.white,
  ),
)
```

### Theme Properties

The `KanbanBoardTheme` class allows you to customize the following colors:

- `backgroundColor`: The background color of the entire board
- `columnColor`: The background color of each column
- `cardColor`: The background color of the cards
- `cardBorderColor`: The border color of the cards
- `headerColor`: The background color of column headers
- `footerColor`: The background color of column footers

### Interaction Guidelines

The Kanban board supports two types of item movement:

1. **Drag and Drop**
   - Drag items within a column to reorder them
   - Visual feedback indicates when dragging is in progress
   - Items cannot be dropped in columns that are at their limit

2. **Button Controls**
   - Left/right buttons for moving items between columns
   - Buttons are automatically disabled when:
     - There is no adjacent column in that direction
     - The target column is at its limit
   - Tooltips provide additional context for button actions

### Column Limits

Column limits are optional and flexible:
- Columns without specified limits can hold unlimited items
- When a limit is set, it is strictly enforced:
  - Visual indicators show current count vs. limit
  - Movement controls are disabled when target column is full
  - Drag and drop operations respect column limits
  - Add item button is disabled when column is full
- Limits can be set per column, allowing mixed unlimited and limited columns

## Example

Check out the [example](example) directory for a complete sample application using the Simple Kanban widget.

To run the example:

1. Clone this repository
2. Navigate to the example directory
3. Run `flutter pub get`
4. Run `flutter run`

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## TODO

- [ ] Add animated GIFs demonstrating:
  - Drag and drop reordering within columns
  - Column-to-column movement with button controls
  - Column limit enforcement and feedback
  - Mixed limited/unlimited column behavior
  - Card interactions and visual feedback
  - Adding new items to limited vs unlimited columns

- [ ] Test Scenarios:
  - [ ] Verify unlimited columns accept items beyond typical limits
  - [ ] Test movement between limited and unlimited columns
  - [ ] Validate limit enforcement when moving items
  - [ ] Check visual indicators for both column types
  - [ ] Verify add item behavior in both column types
  - [ ] Test drag and drop between different column types
  - [ ] Validate button states for all column combinations
  - [ ] Check tooltip accuracy for movement controls
