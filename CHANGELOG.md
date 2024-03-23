# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- build of image for linux/arm64

### Changed

- base image amazoncorretto:8-alpine3.19-jdk (faster startup)

## [1.1.0] - 2024-03-23

### Changed

- base image ubuntu:22.04

### Fixed

- docker_publish workflow latest tag

## [1.0.0] - 2024-03-23

### Added

- docker publish workflow
- gitignore
- this CHANGELOG
- SKIP_PROXY env
- cmis server based on exoplatform/jdk:8-ubuntu-1804

### Changed

- mantainer label (kept reference to exo platform)

### Fixed

- link to maven repo central
- apt install command