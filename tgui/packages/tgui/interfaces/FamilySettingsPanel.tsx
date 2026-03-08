import { useState, useEffect } from 'react';
import { Window } from 'tgui/layouts';
import { useBackend } from 'tgui/backend';
import { Button, Box, Stack, Input, Dropdown } from 'tgui-core/components';

type FamilyType = 'none' | 'member' | 'parent' | 'couple';

type SpeciesMode =
  | 'ANY'
  | 'SAME_TYPE'
  | 'SPECIFIC_TYPE';

type GenderPref = 'any' | 'same' | 'opposite';

type AnatomyPref = 0 | 1 | 2;

type DropdownOption<T extends string | number> = {
  value: T;
  displayText: string;
};

export const FamilySettingsPanel = () => {
  const { act, data } = useBackend();

  const settings = data?.familySettings;
  const speciesList: string[] = data?.availableSpecies || [];

  const isAdult = settings?.age === 'Adult';

  const [familyType, setFamilyType] = useState<FamilyType>('none');
  const [speciesPreferenceMode, setSpeciesPreferenceMode] = useState<SpeciesMode>('ANY');
  const [preferredSpeciesType, setPreferredSpeciesType] = useState<string | null>(null);
  const [preferredSpeciesAnatomy, setPreferredSpeciesAnatomy] = useState<AnatomyPref>(0);
  const [genderPreference, setGenderPreference] = useState<GenderPref>('any');
  const [favoriteName, setFavoriteName] = useState('');
  const [initialized, setInitialized] = useState(false);

  useEffect(() => {
    if (!settings || initialized) return;

    setFamilyType(settings.familyType ?? 'none');
    setSpeciesPreferenceMode(settings.speciesPreferenceMode ?? 'ANY');
    setPreferredSpeciesType(settings.preferredSpeciesType ?? null);
    setPreferredSpeciesAnatomy(settings.preferredSpeciesAnatomy ?? 0);
    setGenderPreference(settings.genderPreference ?? 'any');
    setFavoriteName(settings.favoriteName ?? '');

    setInitialized(true);
  }, [settings, initialized]);

  useEffect(() => {
    if (isAdult && familyType === 'parent') {
      setFamilyType('member');
    }
  }, [isAdult, familyType]);

  const tooltips = {
    none: 'Ваш персонаж не будет участвовать в семейной системе.',
    member: 'Ваш персонаж попытается попасть в существующую семью как ребенок, брат, сестра или другой родственник.',
    parent: 'Ваш персонаж попытается попасть в семью как взрослый супруг или родитель, а при отсутствии подходящей семьи может основать новую.',
    couple: 'Ваш персонаж попытается получить супруга или супругу среди других игроков с такой же настройкой.',
  };

  const familyTypeOptions: DropdownOption<FamilyType>[] = [
    { value: 'none', displayText: 'Нет' },
    { value: 'member', displayText: 'Родственник' },
    { value: 'parent', displayText: 'Родитель / супруг' },
    { value: 'couple', displayText: 'Супружеская пара' },
  ].filter(opt => !(opt.value === 'parent' && isAdult));

  const speciesOptions: DropdownOption<SpeciesMode>[] = [
    { value: 'ANY', displayText: 'Любая' },
    { value: 'SAME_TYPE', displayText: 'Тот же тип' },
    { value: 'SPECIFIC_TYPE', displayText: 'Конкретная раса' },
  ];

  const genderOptions: DropdownOption<GenderPref>[] = [
    { value: 'any', displayText: 'Любой' },
    { value: 'same', displayText: 'Тот же пол' },
    { value: 'opposite', displayText: 'Противоположный' },
  ];

  const anatomyOptions: DropdownOption<AnatomyPref>[] = [
    { value: 0, displayText: 'Без разницы' },
    { value: 1, displayText: 'Мужская анатомия' },
    { value: 2, displayText: 'Женская анатомия' },
  ];

  const getDisplayText = <T extends string | number>(
    options: DropdownOption<T>[],
    value: T | null | undefined
  ) => options.find(opt => opt.value === value)?.displayText || '';

  return (
    <Window title="Настройка семьи" width={600} height={600}>
      <Window.Content>
        <Stack vertical fill>

          <Stack.Item>
            <h2 style={{ textAlign: 'center' }}>
              Настройка семейных отношений
            </h2>
          </Stack.Item>

          <Stack.Item>
            <Box style={{ marginBottom: '4px', fontWeight: 'bold' }}>
              Семейная роль:
            </Box>

            <Dropdown
              options={familyTypeOptions.map(opt => opt.displayText)}
              selected={getDisplayText(familyTypeOptions, familyType)}
              onSelected={(selectedText) => {
                const selectedOption = familyTypeOptions.find(
                  opt => opt.displayText === selectedText
                );
                if (selectedOption)
                  setFamilyType(selectedOption.value as FamilyType);
              }}
              width="100%"
            />

            <Box style={{
              marginTop: '4px',
              fontSize: '12px',
              color: '#aaa',
              fontStyle: 'italic',
              paddingLeft: '4px',
            }}>
              {tooltips[familyType]}
            </Box>
          </Stack.Item>

          {familyType !== 'none' && (
            <>
              <Stack.Divider />

              <Stack.Item>
                <Box style={{ marginBottom: '4px' }}>
                  Предпочтение по расе:
                </Box>

                <Dropdown
                  options={speciesOptions.map(opt => opt.displayText)}
                  selected={getDisplayText(speciesOptions, speciesPreferenceMode)}
                  onSelected={(selectedText) => {
                    const selectedOption = speciesOptions.find(
                      opt => opt.displayText === selectedText
                    );
                    if (selectedOption)
                      setSpeciesPreferenceMode(selectedOption.value);
                  }}
                  width="100%"
                />
              </Stack.Item>

              {speciesPreferenceMode === 'SPECIFIC_TYPE' && (
                <Stack.Item>
                  <Box>Выберите расу:</Box>
                  <Dropdown
                    options={speciesList}
                    selected={preferredSpeciesType || ''}
                    onSelected={(value) => setPreferredSpeciesType(value)}
                    width="100%"
                  />
                </Stack.Item>
              )}

              <Stack.Item>
                <Box style={{ marginBottom: '4px' }}>
                  Предпочтительная анатомия:
                </Box>

                <Dropdown
                  options={anatomyOptions.map(opt => opt.displayText)}
                  selected={getDisplayText(anatomyOptions, preferredSpeciesAnatomy)}
                  onSelected={(selectedText) => {
                    const selectedOption = anatomyOptions.find(
                      opt => opt.displayText === selectedText
                    );
                    if (selectedOption)
                      setPreferredSpeciesAnatomy(selectedOption.value as AnatomyPref);
                  }}
                  width="100%"
                />
              </Stack.Item>

              <Stack.Item>
                <Box style={{ marginBottom: '4px' }}>
                  Предпочтение по полу:
                </Box>

                <Dropdown
                  options={genderOptions.map(opt => opt.displayText)}
                  selected={getDisplayText(genderOptions, genderPreference)}
                  onSelected={(selectedText) => {
                    const selectedOption = genderOptions.find(
                      opt => opt.displayText === selectedText
                    );
                    if (selectedOption)
                      setGenderPreference(selectedOption.value as GenderPref);
                  }}
                  width="100%"
                />
              </Stack.Item>

              <Stack.Item>
                <Input
                  placeholder="Имя фаворита"
                  value={favoriteName}
                  onChange={setFavoriteName}
                  fluid
                />
              </Stack.Item>
            </>
          )}

          <Stack.Item mt={2}>
            <Button
              fluid
              color="good"
              onClick={() => {
                act('save', {
                  familyType,
                  speciesPreferenceMode,
                  preferredSpeciesType,
                  preferredSpeciesAnatomy,
                  genderPreference,
                  favoriteName,
                });
              }}
            >
              Сохранить настройки
            </Button>
          </Stack.Item>

        </Stack>
      </Window.Content>
    </Window>
  );
};
