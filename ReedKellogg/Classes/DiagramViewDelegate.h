@protocol DiagramViewDelegate

- (void) handleSingleDragFrom:(UIPanGestureRecognizer *)recognizer;
- (void) handleDoubleDragFrom:(UIPanGestureRecognizer *)recognizer;
- (void) handleSingleTapFrom:(UIRotationGestureRecognizer *)recognizer;

@end