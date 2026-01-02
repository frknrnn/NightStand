#include "modelmanager.h"

ModelManager::ModelManager(QObject *parent)
    : QObject{parent}
{
    init();
}

void ModelManager::init()
{
    m_dateTimeModel = new DateTimeModel();
}

ModelManager* ModelManager::m_instance = nullptr;

ModelManager *ModelManager::instance()
{
    if(!m_instance){
        m_instance = new ModelManager();
    }
    return m_instance;
}

DateTimeModel* ModelManager::GetDateTimeModel()
{
    return m_dateTimeModel;
}

ModelManager::~ModelManager()
{
}
