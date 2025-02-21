# Simple Kanban

A simple, customizable Kanban board widget for Flutter applications.

> This widget was developed with the assistance of [Cursor](https://cursor.sh/), an AI-powered code editor.

## Features

- Modern, clean card design with subtle visual feedback
- Customizable columns with equal widths and height that expands to the container
- Mandatory headers with text labels and item count indicators
- Items displayed as cards with modern typography and layout
- Intuitive drag-and-drop reordering within columns
- Easy column-to-column movement with directional controls
- Flexible column limits (optional per column)
- Smart button states that reflect available actions
- Customizable themes and colors with dark mode support
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
- Configurable add item functionality per column
- Item count with optional limit indicator
- Optional column limits (unlimited by default)
- Visual feedback when columns reach their limit
- Smooth drag-and-drop reordering
- Customizable column titles and limits

### Theme Support
- Light and dark mode themes
- Customizable colors for all components
- Automatic theme adaptation based on system settings
- Consistent visual hierarchy in both modes

## Examples

### Basic Usage with Custom Columns

```dart
import 'package:flutter/material.dart';
import 'package:simple_kanban/simple_kanban.dart';

// Example items for each column
final backlogItems = [
  KanbanItem(
    id: '1',
    title: 'Design User Interface',
    subtitle: 'github.com/org/repo/issues/123',
  ),
  KanbanItem(
    id: '2',
    title: 'Setup CI/CD Pipeline',
    subtitle: 'Link to Jenkins configuration',
  ),
];

final inProgressItems = [
  KanbanItem(
    id: '3',
    title: 'User Authentication',
    subtitle: 'PR: github.com/org/repo/pull/456',
  ),
];

final reviewItems = [
  KanbanItem(
    id: '4',
    title: 'API Integration',
    subtitle: 'Pending review: github.com/org/repo/pull/789',
  ),
];

final doneItems = [
  KanbanItem(
    id: '5',
    title: 'Project Setup',
    subtitle: 'Completed on 2024-01-20',
  ),
];

// Create a custom Kanban board with 4 columns and dark mode support
KanbanBoard(
  theme: KanbanBoardTheme(
    backgroundColor: isDark ? Color(0xFF1E1E1E) : Colors.grey.shade100,
    columnColor: isDark ? Color(0xFF2D2D2D) : Colors.white,
    cardColor: isDark ? Color(0xFF3D3D3D) : Colors.blue.shade50,
    cardBorderColor: isDark ? Color(0xFF505050) : Colors.blue.shade200,
    headerColor: isDark ? Color(0xFF0D47A1) : Colors.blue.shade500,
    headerTextColor: Colors.white,
    cardTitleColor: isDark ? Colors.white : Colors.black87,
    cardSubtitleColor: isDark ? Colors.grey.shade300 : Colors.black54,
    countTextColor: isDark ? Colors.grey.shade300 : Colors.black87,
  ),
  columns: [
    KanbanColumnConfig(
      title: 'Backlog',
      initialItems: backlogItems,
      canAddItems: true,
    ),
    KanbanColumnConfig(
      title: 'In Progress',
      initialItems: inProgressItems,
      limit: 2,
      canAddItems: true,
    ),
    KanbanColumnConfig(
      title: 'Review',
      initialItems: reviewItems,
      limit: 3,
    ),
    KanbanColumnConfig(
      title: 'Done',
      initialItems: doneItems,
      canAddItems: true,
    ),
  ],
)
```

### Using Standard Three-Column Layout

```dart
// Create a standard Kanban board with predefined columns
KanbanBoard.standard(
  theme: KanbanBoardTheme(
    backgroundColor: Colors.grey.shade100,
    columnColor: Colors.white,
    cardColor: Colors.blue.shade50,
    cardBorderColor: Colors.blue.shade200,
    headerColor: Colors.blue.shade500,
    headerTextColor: Colors.white,
    cardTitleColor: Colors.black87,
    cardSubtitleColor: Colors.black54,
    countTextColor: Colors.black87,
  ),
  // Optional: Provide initial items for each column
  backlogItems: [
    KanbanItem(
      id: '1',
      title: 'New Feature',
      subtitle: 'Planning phase',
    ),
  ],
  inProgressItems: [
    KanbanItem(
      id: '2',
      title: 'Current Task',
      subtitle: 'In development',
    ),
  ],
  doneItems: [
    KanbanItem(
      id: '3',
      title: 'Completed Item',
      subtitle: 'Ready for release',
    ),
  ],
  // Optional: Configure column limits
  backlogLimit: null,  // Unlimited
  workInProgressLimit: 3,  // Limited to 3 items
  doneLimit: null,  // Unlimited
)
```

### Theme Properties

The `KanbanBoardTheme` class allows you to customize the following colors:

- `backgroundColor`: The background color of the entire board
- `columnColor`: The background color of each column
- `cardColor`: The background color of the cards
- `cardBorderColor`: The border color of the cards
- `headerColor`: The background color of column headers
- `headerTextColor`: The text color of column headers
- `cardTitleColor`: The text color of card titles
- `cardSubtitleColor`: The text color of card subtitles
- `countTextColor`: The text color of item count badges

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
  - Adding new items to limited vs unlimited columns
  - Dark mode transitions

- [ ] Mobile Layout Improvements - need a better layout for mobile

# License

MIT License

Copyright (c) [2025] [Darren KinWah Lai]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

1. The above copyright notice and this permission notice shall be included in
   all copies or substantial portions of the Software.

2. THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
   SOFTWARE.

