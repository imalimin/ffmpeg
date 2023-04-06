cmake_minimum_required(VERSION 3.4.1)
project(rtmp LANGUAGES C)

set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -DNO_CRYPTO")

file(GLOB SOURCES *.c)

add_library(rtmp SHARED ${SOURCES})