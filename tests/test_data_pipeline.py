"""Smoke tests for the data pipeline structure."""


def test_pipeline_module_imports():
    import ml.src.data.pipeline  # noqa: F401


def test_data_package_exists():
    import ml.src.data

    assert ml.src.data is not None
