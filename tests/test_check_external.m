function test_suite=test_check_external()
    initTestSuite;

function test_check_external_nifti()
    % nifti comes with CoSMoMVPA, so should always be available if the path
    % is set properly

    warning_state=cosmo_warning();
    orig_path=path();
    run_sequentially=@(varargin)cellfun(@(f)f(),varargin);
    cleaner=onCleanup(@()run_sequentially(...
                            @()path(orig_path),...
                            @()cosmo_warning(warning_state)));

    % ensure path is set; disable warnings by cosmo_set_path
    cosmo_warning('off');
    cosmo_set_path();

    assertTrue(cosmo_check_external('nifti'))
    assertEqual(cosmo_check_external({'nifti','nifti'}),[true;true]);

    % test list
    externals=cosmo_check_external('-list');
    assert(~isempty(strmatch('nifti',externals,'exact')));

    % test tic/toc
    cosmo_check_external('-tic');
    assert(isempty(cosmo_check_external('-toc')));

    % must cite CoSMoMVPA, but not NIFTI
    c=cosmo_check_external('-cite');
    assert(~isempty(findstr(c,'N. N. Oosterhof')));
    assert(~isempty(findstr(c,'CoSMoMVPA')));
    assert(isempty(findstr(c,'NIFTI toolbox')));

    % after checking for nifti it must be present
    cosmo_check_external('nifti');
    assertEqual(cosmo_check_external('-toc'),{'nifti'});
    c=cosmo_check_external('-cite');
    assert(~isempty(findstr(c,'NIFTI toolbox')));

    % removing nifti from the path makes it absent
    rmpath(fileparts(which('load_nii')));
    assertFalse(cosmo_check_external('nifti',false));

    % throws exception when second argument is true or absent
    assertExceptionThrown(@()cosmo_check_external('nifti',true),'');
    assertExceptionThrown(@()cosmo_check_external('nifti'),'');


function test_check_external_mocov()
    has_mocov=~isempty(which('mocov'));
    assertEqual(has_mocov,cosmo_check_external('mocov',false));


function test_check_external_exceptions()
    aet=@(varargin)assertExceptionThrown(@()...
                    cosmo_check_external(varargin{:}),'');
    aet('unknown package');