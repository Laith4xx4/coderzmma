using AutoMapper;
using WebApplication1.Models;
using WebApplication1.DTOs;

namespace WebApplication1.MappingProfiles
{
    public class ClassTypeMapping : Profile
    {
        public ClassTypeMapping()
        {
            CreateMap<ClassType, ClassTypeResponseDto>()
                .ForMember(dest => dest.SessionsCount, opt => opt.MapFrom(src => src.Sessions.Count));

            CreateMap<CreateClassTypeDto, ClassType>();
            CreateMap<UpdateClassTypeDto, ClassType>();
        }
    }
}
