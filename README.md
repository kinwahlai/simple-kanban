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
- Strict column limits with visual feedback
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
- Item count with limit indicator
- Strict enforcement of column limits
- Visual feedback when columns are full
- Smooth drag-and-drop reordering
- Add new items through text input
- Customizable column titles and limits

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
  
  // Custom limits for each column
  columnLimits: {
    'To Do': 6,
    'In Progress': 4,
    'Done': 8,
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

Column limits are strictly enforced:
- Visual indicators show current count vs. limit
- Movement controls are disabled when target column is full
- Drag and drop operations respect column limits
- Add item button is disabled when column is full

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
  - Drag and drop reordering
  - Column-to-column movement
  - Column limit enforcement
  - Card interactions and visual feedback
  - Adding new items
