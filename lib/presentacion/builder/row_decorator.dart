class ExerciseRow {
  final List<String> cells;
  final bool isBlockSeparator;
  final bool isSuperserie;

  ExerciseRow({
    required this.cells,
    this.isBlockSeparator = false,
    this.isSuperserie = false,
  });
}