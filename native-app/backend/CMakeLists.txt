cmake_minimum_required(VERSION 3.20)
project(CPUSchedulerBackend LANGUAGES C CXX OBJC OBJCXX)

set(CMAKE_C_STANDARD 11)
set(CMAKE_C_STANDARD_REQUIRED ON)
set(CMAKE_C_EXTENSIONS OFF)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O2 -Wall -Wextra -Wpedantic")

add_library(cpu_scheduler_core STATIC
    Sources/Core/process_monitor.c
    Sources/Core/scheduler.c
    Sources/Core/metrics.c
    Sources/Core/utils.c
)

target_include_directories(cpu_scheduler_core PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/Sources/Core
)

if(APPLE)
    target_link_libraries(cpu_scheduler_core PUBLIC
        "-framework Foundation"
    )

    add_library(cpu_scheduler_bridge STATIC
        Sources/Bridge/SchedulerBridge.mm
        Sources/Bridge/ProcessMonitorBridge.mm
        Sources/Bridge/TypeConverters.mm
    )

    target_include_directories(cpu_scheduler_bridge PUBLIC
        ${CMAKE_CURRENT_SOURCE_DIR}/Sources/Core
        ${CMAKE_CURRENT_SOURCE_DIR}/Sources/Bridge
        ${CMAKE_CURRENT_SOURCE_DIR}/Sources/Include
    )

    target_link_libraries(cpu_scheduler_bridge PUBLIC
        cpu_scheduler_core
        "-framework Foundation"
    )

    set_source_files_properties(
        Sources/Bridge/SchedulerBridge.mm
        Sources/Bridge/ProcessMonitorBridge.mm
        Sources/Bridge/TypeConverters.mm
        PROPERTIES COMPILE_FLAGS "-fobjc-arc"
    )
endif()

add_executable(standalone_demo Examples/standalone_demo.c)
target_link_libraries(standalone_demo PRIVATE cpu_scheduler_core)

include(CTest)
if(BUILD_TESTING)
    add_executable(test_scheduler Tests/test_scheduler.c)
    target_link_libraries(test_scheduler PRIVATE cpu_scheduler_core)
    add_test(NAME SchedulerTest COMMAND test_scheduler)

    add_executable(test_metrics Tests/test_metrics.c)
    target_link_libraries(test_metrics PRIVATE cpu_scheduler_core)
    add_test(NAME MetricsTest COMMAND test_metrics)

    add_executable(test_monitor Tests/test_monitor.c)
    target_link_libraries(test_monitor PRIVATE cpu_scheduler_core)
    add_test(NAME MonitorTest COMMAND test_monitor)
endif()
