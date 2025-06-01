package builder

import "core:log"
import "core:strings"
import "core:slice"
import os "core:os/os2"

check_build_directory :: proc(build_path: string) {
	if !os.exists(build_path) {
		os.make_directory(build_path)
	}
}

build :: proc(source_path: string, output: string, flags: string) {
	builder: strings.Builder
	defer strings.builder_destroy(&builder)

	strings.write_string(&builder, "odin build ")
	strings.write_string(&builder, source_path)
	strings.write_string(&builder, " -out:")
	strings.write_string(&builder, output)
	strings.write_string(&builder, " ")
	strings.write_string(&builder, flags)

	build_command := strings.to_string(builder)

	execute_command(build_command)
}

run :: proc(output: string) {
	if slice.contains(os.args, "run") {
		execute({output})
	}
}

execute_command :: proc(command: string) {
	execute(strings.split(command, " "))
}

execute :: proc(command: []string) {
	log.infof("Running {}", command)

	process, process_err := os.process_start({command = command, stdin = os.stdin, stdout = os.stdout, stderr = os.stderr })
	if process_err != nil {
		log.errorf("Error executing process: {}", process_err)
		os.exit(1)
	}

	state, state_err := os.process_wait(process)
	if state_err != nil {
		log.errorf("Error executing process: {}", state_err)
		os.exit(1)
	}

	close_err := os.process_close(process)
	if close_err != nil {
		log.errorf("Error executing process: {}", close_err)
		os.exit(1)
	}
	
	if state.exit_code != 0 {
		log.errorf("Process exited with non-zero code: {}", state.exit_code)
		os.exit(1)
	}
}