# Simple Kanban

A simple, customizable Kanban board widget for Flutter applications.

> This widget was developed with the assistance of [Cursor](https://cursor.sh/), an AI-powered code editor.

## Features

- Modern, clean card design with subtle visual feedback
- Three columns with equal widths and height that expands to the container
- Mandatory headers with text labels and item count indicators
- Optional footers with add item functionality (configurable per column)
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
- Mandatory headers with item count indicators
- Optional footers for adding new items
- Configurable add item functionality per column
- Item count with optional limit indicator
- Optional column limits (unlimited by default)
- Visual feedback when columns reach their limit
- Smooth drag-and-drop reordering
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

### Mixed Limited and Unlimited Columns with Selective Add Functionality

```dart
KanbanBoard(
  columnTitles: ['Backlog', 'In Progress', 'Done'],
  // Only Backlog column can add new items
  columnsWithFooter: {'Backlog'},
  // In Progress is limited, others are unlimited
  columnLimits: {
    'In Progress': 3,  // Limited to 3 items
  },
  initialItems: {
    'Backlog': [
      KanbanItem(id: '1', title: 'New Feature', subtitle: 'Planning phase'),
    ],
    'In Progress': [
      KanbanItem(id: '2', title: 'Current Task', subtitle: 'In development'),
    ],
    'Done': [
      KanbanItem(id: '3', title: 'Completed Item', subtitle: 'Ready for release'),
    ],
  },
)
```

### Column Configuration Options

The board supports various column configurations:

1. **Headers (Mandatory)**
   - Always visible
   - Shows column title
   - Displays item count
   - Shows limit if configured

2. **Footers (Optional)**
   - Can be enabled/disabled per column
   - Provides add item functionality
   - Only shown in specified columns
   - Typical use cases:
     - Backlog column with add functionality
     - Work columns for tracking only
     - Archive columns for completed items

3. **Common Configurations**
   - Backlog: Footer enabled, no limit
   - Work in Progress: No footer, with limit
   - Done: No footer, no limit

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
  
  // Specify which columns should have add item functionality
  columnsWithFooter: {'To Do'},  // Only To Do column can add items
  
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
