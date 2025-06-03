package spacelift

format_violation(violation) = formatted_violation {
    message := "%s: %s in %s (line %d to %d)"
    formatted_violation := sprintf(message, [violation.rule.name, violation.message, violation.range.filename, violation.range.start.line, violation.range.end.line])
}

deny[sprintf(message, [failures])] {
    message := "You have failed TFLint checks: %d"
    failures := count(input.third_party_metadata.custom.tflint.issues)
    failures > 0
}

warn[sprintf(message, [violations_count, violations_report])] {
    message := "You have %d TFLint warnings:\n%s"
    violations := input.third_party_metadata.custom.tflint.issues
    violations_report := concat("\n", [format_violation(violation) | violation := violations[_]])
    violations_count := count(violations)
    violations_count > 0
}

sample = true
