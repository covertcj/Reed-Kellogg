@protocol DiagramViewDelegate

- (void) handleSingleDragFrom:(UIPanGestureRecognizer *)recognizer;
- (void) handleDoubleDragFrom:(UIPanGestureRecognizer *)recognizer;
- (void) handleSingleTapFrom:(UITapGestureRecognizer *)recognizer;
- (void) handleDoubleTapFrom:(UITapGestureRecognizer *)recognizer;

@end